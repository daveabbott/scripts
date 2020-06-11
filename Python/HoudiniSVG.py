node = hou.pwd()
geo = node.geometry()

# Add code to modify contents of geo.
# Use drop down menu to select examples.

fileout = node.evalParm('fileOut')
maxsize = node.evalParm('maxSize')
stroke_width = node.evalParm('strokeWidth')

box = geo.boundingBox()
minv = box.minvec()
size = box.sizevec()

if size.x() > size.y():
  width = maxsize
  height = maxsize * size.y() / size.x()
else:
  width = maxsize * size.x() / size.y()
  height = maxsize

def write_path(fp, points):
  if not points:
    return
  data = 'M{} {} '.format(points[0].x(), points[0].y())
  for p in points[1:]:
    data += 'L{} {} '.format(p.x(), p.y())
  fp.write('<path d="{}" stroke="black" stroke-width="{}px" fill="none"/>\n'.format(data, stroke_width))

def transform_points(points):
  for p in points:
    p = hou.Vector2(
      (p.x() - minv.x()) / size.x() * width,
      (p.y() - minv.y()) / size.y() * height
    )
    yield p

with open(fileout, 'w') as fp:
  fp.write('<?xml version="1.0" standalone="no"?>\n')
  fp.write('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n')
  fp.write('<svg width="{}mm" height="{}mm" version="1.1" xmlns="http://www.w3.org/2000/svg">\n'.format(width, height))
  for prim in geo.iterPrims():
    if prim.type() != hou.primType.Polygon:
      continue
    points = [v.point().position() for v in prim.vertices()]
    points = list(transform_points(points))
    write_path(fp, points)
  fp.write('</svg>')