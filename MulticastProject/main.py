import asyncio
import websockets

# WebSocket server handler
async def notify_clients(websocket, path):
    print(f"New connection on path: {path}")
    try:
        async for message in websocket:
            print(f"Received message: {message}")
            if message == "start_stream":
                await websocket.send("refresh_screen")
                print("Sent 'refresh_screen' to client")
    except websockets.exceptions.ConnectionClosedError as e:
        print(f"WebSocket connection closed with error: {e}")
    except websockets.exceptions.ConnectionClosedOK:
        print("WebSocket connection closed normally.")
    except Exception as e:
        print(f"An error occurred: {e}")

async def start_server():
    server = await websockets.serve(notify_clients, "192.168.1.8", 8765)
    print("WebSocket server started on ws://192.168.1.8:8765")
    await asyncio.Future()  # Giữ server chạy mãi mãi

if __name__ == "__main__":
    asyncio.run(start_server())