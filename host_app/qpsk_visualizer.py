import csv
import math
import os
import random
import struct
import sys
import threading
import time
import tkinter as tk
from tkinter import filedialog, messagebox, ttk


class QpskVisualizer(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("QPSK Baseband Visualizer")
        self.geometry("980x640")
        self.samples = []
        self.running = False
        self.serial_thread = None

        self.port_var = tk.StringVar(value="COM3")
        self.status_var = tk.StringVar(value="Ready")
        self.ber_var = tk.StringVar(value="BER: --")
        self.count_var = tk.StringVar(value="Samples: 0")

        self._build_ui()
        self.after(100, self._draw)

    def _build_ui(self):
        top = ttk.Frame(self, padding=8)
        top.pack(fill=tk.X)

        ttk.Button(top, text="Load CSV", command=self.load_csv).pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="Demo", command=self.demo_data).pack(side=tk.LEFT, padx=4)
        ttk.Label(top, text="Serial").pack(side=tk.LEFT, padx=(24, 4))
        ttk.Entry(top, textvariable=self.port_var, width=10).pack(side=tk.LEFT)
        ttk.Button(top, text="Start", command=self.start_serial).pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="Stop", command=self.stop_serial).pack(side=tk.LEFT, padx=4)
        ttk.Button(top, text="Clear", command=self.clear).pack(side=tk.LEFT, padx=4)

        ttk.Label(top, textvariable=self.ber_var).pack(side=tk.RIGHT, padx=12)
        ttk.Label(top, textvariable=self.count_var).pack(side=tk.RIGHT, padx=12)

        body = ttk.Frame(self, padding=(8, 0, 8, 8))
        body.pack(fill=tk.BOTH, expand=True)

        self.const_canvas = tk.Canvas(body, bg="#101820", highlightthickness=0)
        self.const_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 4))

        right = ttk.Frame(body)
        right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(4, 0))
        self.wave_canvas = tk.Canvas(right, bg="#111111", height=260, highlightthickness=0)
        self.wave_canvas.pack(fill=tk.BOTH, expand=True)
        self.info = tk.Text(right, height=10, wrap=tk.WORD)
        self.info.pack(fill=tk.X, pady=(8, 0))
        self.info.insert(tk.END, "QPSK visualization\n\n")
        self.info.insert(tk.END, "Load CSV: open sim/qpsk_samples.csv after ModelSim simulation.\n")
        self.info.insert(tk.END, "Serial: connect FPGA uart_txd to USB-TTL RX, common GND, 115200 baud.\n")
        self.info.configure(state=tk.DISABLED)

        bottom = ttk.Label(self, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W, padding=4)
        bottom.pack(fill=tk.X)

    def clear(self):
        self.samples = []
        self.status_var.set("Cleared")
        self._update_labels()

    def load_csv(self):
        path = filedialog.askopenfilename(
            title="Open QPSK CSV",
            filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
        )
        if not path:
            return
        loaded = []
        with open(path, newline="") as f:
            reader = csv.DictReader(f)
            for row in reader:
                loaded.append((
                    int(row["i_tx"]),
                    int(row["q_tx"]),
                    int(row["i_rx"]),
                    int(row["q_rx"]),
                    None,
                    None,
                ))
        self.samples = loaded[-2000:]
        self.status_var.set(f"Loaded {os.path.basename(path)}")
        self._update_labels()

    def demo_data(self):
        points = [(1024, 1024), (-1024, 1024), (-1024, -1024), (1024, -1024)]
        out = []
        errors = 0
        total = 0
        for n in range(800):
            i_tx, q_tx = points[n % 4]
            angle = math.radians(10)
            i_rot = i_tx * math.cos(angle) - q_tx * math.sin(angle)
            q_rot = i_tx * math.sin(angle) + q_tx * math.cos(angle)
            i_rx = int(i_rot + random.gauss(0, 90))
            q_rx = int(q_rot + random.gauss(0, 90))
            total += 2
            if (i_tx >= 0) != (i_rx >= 0):
                errors += 1
            if (q_tx >= 0) != (q_rx >= 0):
                errors += 1
            out.append((i_tx, q_tx, i_rx, q_rx, total, errors))
        self.samples = out
        self.status_var.set("Demo data generated")
        self._update_labels()

    def start_serial(self):
        if self.running:
            return
        try:
            import serial
        except ImportError:
            messagebox.showerror("Missing pyserial", "Install pyserial first: python -m pip install pyserial")
            return

        self.running = True
        port = self.port_var.get().strip()
        self.serial_thread = threading.Thread(target=self._serial_loop, args=(serial, port), daemon=True)
        self.serial_thread.start()
        self.status_var.set(f"Reading {port} at 115200 baud")

    def stop_serial(self):
        self.running = False
        self.status_var.set("Serial stopped")

    def _serial_loop(self, serial_mod, port):
        try:
            ser = serial_mod.Serial(port, 115200, timeout=0.2)
        except Exception as exc:
            self.running = False
            self.after(0, lambda: messagebox.showerror("Serial open failed", str(exc)))
            return

        buf = bytearray()
        while self.running:
            buf.extend(ser.read(64))
            while len(buf) >= 18:
                if buf[0] != 0x55 or buf[1] != 0xAA:
                    del buf[0]
                    continue
                frame = bytes(buf[:18])
                del buf[:18]
                i_tx, q_tx, i_rx, q_rx = struct.unpack("bbbb", frame[2:6])
                total = int.from_bytes(frame[6:10], "big")
                errors = int.from_bytes(frame[10:14], "big")
                self.samples.append((i_tx * 16, q_tx * 16, i_rx * 16, q_rx * 16, total, errors))
                self.samples = self.samples[-2000:]
                self.after(0, self._update_labels)
        ser.close()

    def _update_labels(self):
        self.count_var.set(f"Samples: {len(self.samples)}")
        total = None
        errors = None
        for sample in reversed(self.samples):
            if sample[4] is not None:
                total = sample[4]
                errors = sample[5]
                break
        if total:
            self.ber_var.set(f"BER: {errors / total:.3e}")
        else:
            self.ber_var.set("BER: --")

    def _draw(self):
        self._draw_constellation()
        self._draw_waveform()
        self.after(120, self._draw)

    def _draw_constellation(self):
        c = self.const_canvas
        c.delete("all")
        w = max(c.winfo_width(), 1)
        h = max(c.winfo_height(), 1)
        cx = w // 2
        cy = h // 2
        scale = min(w, h) / 3000.0
        c.create_line(24, cy, w - 24, cy, fill="#405060")
        c.create_line(cx, 24, cx, h - 24, fill="#405060")
        c.create_text(18, 18, text="Constellation", fill="#f0f0f0", anchor=tk.NW)
        for i_tx, q_tx, i_rx, q_rx, _, _ in self.samples[-1000:]:
            x = cx + int(i_rx * scale)
            y = cy - int(q_rx * scale)
            c.create_oval(x - 2, y - 2, x + 2, y + 2, fill="#2dd4bf", outline="")
        for i, q in [(1024, 1024), (-1024, 1024), (-1024, -1024), (1024, -1024)]:
            x = cx + int(i * scale)
            y = cy - int(q * scale)
            c.create_oval(x - 6, y - 6, x + 6, y + 6, outline="#facc15", width=2)

    def _draw_waveform(self):
        c = self.wave_canvas
        c.delete("all")
        w = max(c.winfo_width(), 1)
        h = max(c.winfo_height(), 1)
        c.create_text(12, 12, text="I/Q waveform", fill="#f0f0f0", anchor=tk.NW)
        data = self.samples[-240:]
        if len(data) < 2:
            return
        mid_i = h * 0.35
        mid_q = h * 0.72
        sx = w / max(len(data) - 1, 1)
        sy = h / 8 / 1024
        last_i = None
        last_q = None
        for idx, sample in enumerate(data):
            x = idx * sx
            yi = mid_i - sample[2] * sy
            yq = mid_q - sample[3] * sy
            if last_i:
                c.create_line(last_i[0], last_i[1], x, yi, fill="#60a5fa", width=2)
                c.create_line(last_q[0], last_q[1], x, yq, fill="#f97316", width=2)
            last_i = (x, yi)
            last_q = (x, yq)
        c.create_text(12, int(mid_i) - 48, text="I", fill="#60a5fa", anchor=tk.W)
        c.create_text(12, int(mid_q) - 48, text="Q", fill="#f97316", anchor=tk.W)


if __name__ == "__main__":
    app = QpskVisualizer()
    app.mainloop()
