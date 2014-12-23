import os.path
import cairo
import argparse
from gi.repository import Rsvg as rsvg

# Python 3!

class Renderer:
    only = []
    force = False
    renderers = []
    @classmethod
    def register(cls, suffix):
        def wrapper(f):
            cls.renderers.append((suffix, f))
            return f
        return wrapper
    
    def __init__(self, source):
        self.source = source
        self.destination = os.path.dirname(source)
        self.mtime = os.path.getmtime(source)
        self.jobs = []
        self.svg = rsvg.Handle.new_from_file(source)
    
    def _get_transformer(self, width=None, height=None, id=None):
        def transformer(svg):
            dim = svg.get_dimensions()
            w = dim.width
            h = dim.height
            if width and height:
                w = width
                h = height
            elif width:
                change = width / w
                w = int(change * w)
                h = int(change * h)
            elif height:
                change = height / h
                w = int(change * w)
                h = int(change * h)
            
            return (w, h, id, svg)
        return transformer
    
    def _do_job_p(self, out):
        try:
            older = os.path.getmtime(os.path.join(self.destination, out)) < self.mtime
        except FileNotFoundError:
            older = True
        allowed = (self.only == []) or (self.source in self.only)
        force = self.force
        return allowed and (older or force)
    
    def render(self, out, **kwargs):
        transformer = self._get_transformer(**kwargs)
        
        for suffix, renderer in self.renderers:
            if self._do_job_p(out + suffix):
                self.jobs.append((out + suffix, transformer, renderer))
    
    def render_raw(self, out, **kwargs):
        transformer = self._get_transformer(**kwargs)
        _, renderer = self.renderers[0]
        
        if self._do_job_p(out):
            self.jobs.append((out, transformer, renderer))
    
    def __enter__(self):
        return self
    
    def __exit__(self, type, value, traceback):
        if type:
            return None
        
        for jobname, transformer, renderer in self.jobs:
            outpath = os.path.join(self.destination, jobname)
            print("{0} --> {1}".format(self.source, jobname))
            
            svg = rsvg.Handle.new_from_file(self.source)
            width, height, id, svg = transformer(svg)
            renderer(svg, width, height, id, outpath)

def timeser(n):
    def times(svg, width, height, id, outpath):
        img = cairo.ImageSurface(cairo.FORMAT_ARGB32, width * n, height * n)
        ctx = cairo.Context(img)
        dim = svg.get_dimensions()
        ctx.scale(width / dim.width, height / dim.height)
        ctx.scale(n, n)
        
        if id:
            svg.render_cairo_sub(ctx, id)
        else:
            svg.render_cairo(ctx)
        img.write_to_png(outpath)
    return times

Renderer.register('.png')(timeser(1))
Renderer.register('@2x.png')(timeser(2))
Renderer.register('@3x.png')(timeser(3))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Render OSU Bus icons from SVG. By default, renders only PNGs that are older than their source SVG, and tries to update all possible icons.')
    parser.add_argument('targets', metavar='TARGET', type=str, nargs='*', help='which SVGs to render')
    parser.add_argument('-f', '--force', dest='force', action='store_const', const=True, default=False, help='ignore mtimes when rendering')
    
    args = parser.parse_args()
    Renderer.force = args.force
    Renderer.only = args.targets
    
    with Renderer('Resources/Springboard/Icon.svg') as r:
        r.render('Icon', width=57)
        r.render('Icon7', width=60)
        r.render('Icon-Small', width=29)
        r.render('Icon-Small7', width=40)
        r.render_raw('iTunesArtwork', width=1024)
    
    with Renderer('Resources/Icons/pin.svg') as r:
        r.render('pin-mask', id='#mask')
        r.render('pin-overlay', id='#overlay')
        r.render('pin-overlay-new', id='#overlay-new')
    
    with Renderer('Resources/Icons/buspin.svg') as r:
        r.render('buspin-mask', id='#mask')
        r.render('buspin-overlay', id='#overlay')
        r.render('buspin-overlay-new', id='#overlay-new')
    
    with Renderer('Resources/Icons/favorites.svg') as r:
        r.render('favorites-add', id='#add')
        r.render('favorites-remove')
    
    with Renderer('Resources/Icons/locate.svg') as r:
        r.render('locate', id='#inactive')
        r.render('locate-active', id='#active')
    
    with Renderer('Resources/Icons/licenses.svg') as r:
        r.render('licenses')
    
    with Renderer('Resources/Icons/info.svg') as r:
        r.render('info')
