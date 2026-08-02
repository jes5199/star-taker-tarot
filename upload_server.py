#!/usr/bin/env python3
"""Simple upload server for receiving image files."""
import http.server
import os
import re

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "images")

HTML = """<!DOCTYPE html>
<html><body>
<h2>Upload Lenormand Illustrations</h2>
<form method="POST" enctype="multipart/form-data">
<input type="file" name="files" multiple accept="image/*">
<br><br>
<input type="submit" value="Upload">
</form>
</body></html>"""

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(HTML.encode())

    def do_POST(self):
        content_length = int(self.headers["Content-Length"])
        content_type = self.headers["Content-Type"]
        body = self.rfile.read(content_length)

        boundary = content_type.split("boundary=")[1].encode()
        parts = body.split(b"--" + boundary)
        saved = []
        for part in parts:
            if b"filename=\"" not in part:
                continue
            match = re.search(rb'filename="([^"]+)"', part)
            if not match:
                continue
            filename = match.group(1).decode()
            # Split headers from file data
            header_end = part.find(b"\r\n\r\n")
            if header_end == -1:
                continue
            file_data = part[header_end + 4:]
            # Remove trailing \r\n-- if present
            if file_data.endswith(b"\r\n"):
                file_data = file_data[:-2]
            path = os.path.join(UPLOAD_DIR, os.path.basename(filename))
            with open(path, "wb") as f:
                f.write(file_data)
            saved.append(filename)

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        msg = "<br>".join(f"Saved: {s}" for s in saved)
        self.wfile.write(f"<html><body><h2>Uploaded {len(saved)} file(s)</h2>{msg}<br><br><a href='/'>Upload more</a></body></html>".encode())

if __name__ == "__main__":
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    server = http.server.HTTPServer(("0.0.0.0", 8888), Handler)
    print(f"Upload server running on http://localhost:8888")
    server.serve_forever()
