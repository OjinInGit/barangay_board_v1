import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final im = img.Image(width: size, height: size);
  final blue = img.ColorRgb8(21, 101, 192);
  final yellow = img.ColorRgb8(249, 168, 37);
  final white = img.ColorRgb8(255, 255, 255);
  img.fill(im, color: blue);
  img.fillRect(im, x1: 220, y1: 420, x2: 804, y2: 820, color: white);
  img.fillRect(im, x1: 260, y1: 320, x2: 764, y2: 440, color: white);
  img.fillRect(im, x1: 280, y1: 440, x2: 340, y2: 820, color: blue);
  img.fillRect(im, x1: 380, y1: 440, x2: 440, y2: 820, color: blue);
  img.fillRect(im, x1: 480, y1: 440, x2: 540, y2: 820, color: blue);
  img.fillRect(im, x1: 580, y1: 440, x2: 640, y2: 820, color: blue);
  img.fillRect(im, x1: 680, y1: 440, x2: 740, y2: 820, color: blue);
  img.fillRect(im, x1: 400, y1: 720, x2: 620, y2: 780, color: yellow);
  final out = File('assets/branding/app_icon.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(im));
}
