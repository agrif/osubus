from django import template
from django.utils.safestring import mark_safe
from osubus_extra.models import ExternalLink, VersionBulletin, CacheDatabase
import re

register = template.Library()

@register.simple_tag
def navlink(request, url, name):
    if request.path == url:
        return name
    return mark_safe('<a href="%s">%s</a>' % (url, name))

@register.simple_tag
def ob_version(fmt="%s"):
    try:
        obj = VersionBulletin.objects.all()[0]
    except IndexError:
        return ""
    return fmt % (str(obj),)

@register.simple_tag
def ob_database(fmt="%s"):
    try:
        obj = CacheDatabase.objects.all()[0]
    except IndexError:
        return ""
    datestr = "%02i/%02i/%04i" % (obj.date.month, obj.date.day, obj.date.year)
    return fmt % (datestr,)

class ExternalLinksNode(template.Node):
    def __init__(self, var_name):
        self.var_name = var_name
    def render(self, context):
        context[self.var_name] = ExternalLink.objects.all()
        return ''

@register.tag
def external_links(parser, token):
    try:
        tag_name, arg = token.contents.split(None, 1)
    except ValueError:
        raise template.TemplateSyntaxError, "%r tag requires arguments" % token.contents.split()[0]
    
    m = re.search(r'as (\w+)', arg)
    if not m:
        raise template.TemplateSyntaxError, "%r tag had invalid arguments" & tag_name
    
    var_name = m.groups()[0]
    return ExternalLinksNode(var_name)
