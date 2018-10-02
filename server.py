from flask import Flask, request, send_file
from cStringIO import StringIO
from PIL import Image

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload():
    images = [Image.open(request.files['pic%d' % pic]) for pic in range(1, 5)]

    # do something with the uploaded images
    images

    # Maybe some QR code as a response?
    # We use a dummy code here. You can of
    # course create something dynamic.
    qr = Image.open("qr-example.png")

    # create response image
    res = Image.new('RGBA', (1920, 1080))
    res.paste(qr, (10,10))

    # Return as PNG
    png = StringIO()
    res.save(png, 'PNG')
    png.seek(0)
    return send_file(png, mimetype='image/png')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8888, debug=False)
