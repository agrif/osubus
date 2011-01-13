#!/usr/bin/python

import os, os.path, sys
import time
import tempfile
import subprocess
import Image
import Tkinter as tk
import tkFileDialog

def processor_none(img):
    return img

def processor_crop(x, y, width, height):
    def processor_crop_intern(img):
        return img.crop((x, y, x+width, y+height))
    return processor_crop_intern

# a list of (name, func) processing pairs
processors = [
    ("None", processor_none),
    ("iPhone", processor_crop(24, 118, 320, 480)),
]

class MainFrame(tk.Frame):
    def __init__(self, *args, **kwargs):
        global processors
        tk.Frame.__init__(self, *args, **kwargs)
        
        #
        # set up UI first
        #
        
        self.columnconfigure(0, weight=1)
        
        outframe = tk.LabelFrame(self, text="Output")
        outframe.columnconfigure(1, weight=1)
        outframe.grid(row=0, sticky=tk.E+tk.W)
        
        tk.Label(outframe, text="Directory:").grid(row=0, column=0, sticky=tk.E)
        self.outvar = tk.StringVar()
        outdir = tk.Entry(outframe, width=30, textvariable=self.outvar)
        outdir.grid(row=0, column=1, sticky=tk.E+tk.W)
        tk.Button(outframe, text="Browse", command=self.browse).grid(row=0, column=2, sticky=tk.E+tk.W)
        
        tk.Label(outframe, text="Format:").grid(row=1, column=0, sticky=tk.E)
        self.fmtvar = tk.StringVar()
        outfmt = tk.Entry(outframe, width=30, textvariable=self.fmtvar)
        outfmt.grid(row=1, column=1, sticky=tk.E+tk.W)
        
        processframe = tk.LabelFrame(self, text="Processing")
        processframe.grid(row=1, sticky=tk.E+tk.W, pady=10)
        subframe = tk.Frame(processframe)
        subframe.pack()
        
        self.processor = tk.IntVar()
        self.processor.set(0)
        for i, obj in enumerate(processors):
            tk.Radiobutton(subframe, text=obj[0], variable=self.processor, value=i).pack(side=tk.LEFT)
        
        subframe = tk.Frame(self)
        subframe.grid(row=2)
        tk.Button(subframe, text="Take Screenshot", command=self.screenshot).pack(side=tk.LEFT)
        tk.Button(subframe, text="Quit", command=self.quit).pack(side=tk.LEFT)
        
        #
        # set up initial values
        #
        
        self.outvar.set(os.getcwd())
        self.fmtvar.set("Screen shot %x at %X PM.png")
    
    def screenshot(self):
        tmp = tempfile.mkstemp(suffix=".png")[1]
        img = None
        try:
            # window mode (only), no shadows
            ret = subprocess.call("screencapture -Wwo " + tmp, shell=True)
            if ret:
                return
            img = Image.open(tmp)
            if not img:
                return
            img.load()
        finally:
            os.remove(tmp)
        
        if not img:
            return
        
        global processors
        img = processors[self.processor.get()][1](img)
        
        out = os.path.join(self.outvar.get(), time.strftime(self.fmtvar.get()).replace('/', '-'))
        img.save(out)
    
    def browse(self):
        dir = tkFileDialog.askdirectory(parent=self, initialdir=self.outvar.get(), title="select an output directory")
        if dir:
            self.outvar.set(dir)

if __name__ == "__main__":
    top = tk.Tk()
    top.title("iOS Simulator Screenshots")
    top.columnconfigure(0, weight=1)
    top.rowconfigure(0, weight=1)
    top.resizable(width=True, height=False)
    frame = MainFrame(top)
    frame.grid(sticky=tk.N+tk.S+tk.E+tk.W, padx=10, pady=10)
    top.mainloop()
