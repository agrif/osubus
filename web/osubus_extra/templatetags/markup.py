import markdown as mkdn

from django import template
from django.utils.encoding import force_text
from django.utils.safestring import mark_safe

register = template.Library()

@register.filter()
def markdown(value, arg=''):
    extensions = [e for e in arg.split(',') if e]
    if extensions and extensions[0] == 'safe':
        extensions = extensions[1:]
        return mark_safe(mkdn.markdown(force_text(value), extensions, safe_mode=True, enable_attributes=False))
    else:
        return mark_safe(mkdn.markdown(force_text(value), extensions, safe_mode=False))
