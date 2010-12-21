from django import template
from osubus_extra.models import ExternalLink
import re

register = template.Library()

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
