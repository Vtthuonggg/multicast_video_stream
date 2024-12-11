import socket
import tkinter as tk
from tkinter import filedialog
import ffmpeg
import asyncio
import websockets

# Cấu hình multicast
MULTICAST_GROUP = '224.1.1.1'
PORT = 5004
BUFFER_SIZE = 1024  # Kích thước gói gửi

# Hàm để chọn video
def choose_video():
    video_path = filedialog.askopenfilename(title="Chọn video", filetypes=(("MP4 Files", "*.mp4"), ("All Files", "*.*")))
    return video_path

# Hàm để stream video
async def stream_video(video_path):
    # Khởi tạo socket UDP multicast
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)  # TTL cho multicast

    # Sử dụng FFmpeg để đọc và chuyển mã video
    process = (
        ffmpeg.input(video_path)
        .output('pipe:', format='mpegts', vcodec='libx264', acodec='mp3')
        .run_async(pipe_stdout=True)
    )

    print(f"Đang stream video tới {MULTICAST_GROUP}:{PORT} ...")

    try:
        # Thông báo cho các client WebSocket
        async with websockets.connect("ws://192.168.1.8:8765") as websocket:
            await websocket.send("start_stream")
            print("Sent 'start_stream' to server")

            while True:
                # Đọc dữ liệu từ FFmpeg và gửi qua multicast
                data = process.stdout.read(BUFFER_SIZE)
                if not data:
                    break
                sock.sendto(data, (MULTICAST_GROUP, PORT))
                print(f"Sent {len(data)} bytes to multicast group")

    except websockets.exceptions.ConnectionClosedError as e:
        print(f"Kết nối WebSocket bị đóng với lỗi: {e}")
    except Exception as e:
        print(f"Đã xảy ra lỗi: {e}")
    finally:
        process.kill()
        sock.close()
        print("Closed process and socket")

async def start_stream(video_path):
    await stream_video(video_path)

def on_choose_video():
    video_file = choose_video()
    if video_file:
        asyncio.run(start_stream(video_file))

def create_gui():
    root = tk.Tk()
    root.title("Video Streamer")

    choose_button = tk.Button(root, text="Chọn Video", command=on_choose_video)
    choose_button.pack(pady=20)

    root.protocol("WM_DELETE_WINDOW", root.quit)
    root.mainloop()

if __name__ == "__main__":
    create_gui()