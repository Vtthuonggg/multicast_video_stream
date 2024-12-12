import asyncio
import websockets

# Duy trì danh sách các client đang kết nối
connected_clients = set()

# WebSocket server handler
async def notify_clients(websocket, path=None):
    print(f"New connection. Path: {path if path else 'Unknown'}")
    connected_clients.add(websocket)
    try:
        async for message in websocket:
            print(f"Received message: {message}")
            if message == "start_stream":
                for client in connected_clients:
                    if client != websocket:
                        await client.send("refresh_screen")
                        print(f"Sent 'refresh_screen' to client")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        connected_clients.remove(websocket)
        print("Connection closed and removed from clients.")



async def start_server():
    server = await websockets.serve(notify_clients, "192.168.1.25", 8765)
    print("WebSocket server started on ws://192.168.1.25:8765")
    await asyncio.Future()  # Giữ server chạy mãi mãi


if __name__ == "__main__":
    asyncio.run(start_server())
