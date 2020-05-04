import Fluent
import Vapor

struct SocketConnection:Identifiable{
    let id = UUID()
    var ws:WebSocket
}
var allSockets = [String:[SocketConnection]]()
func routes(_ app: Application) throws {
    
    app.get { req in
        // When visiting 127.0.0.1:8081 return It works!
        return "It works!"
    }
    
    
    // 制造一个WebSocket的路由在127.0.0.1:8080/sayhello上
    app.webSocket(":room", maxFrameSize: .init(integerLiteral: 20000000)) { req, ws in
        let id = req.parameters.get("room")!
        var room = allSockets[id]
        if room == nil {
            room = []
        }

        let socketConnection = SocketConnection(ws: ws)
        room!.append(socketConnection)
        allSockets[id] = room
        
        //接受二进制信息（你可以用这个接受音频数据）
        ws.onBinary { ws, buffer in
            
            print("Starting to send data!")
            
            
            guard let data = buffer.getData(at: 0, length: buffer.readableBytes) else {
                //如果没有data 就直接退出
                print("Error, cannot get data!")
                return
            }
            //let uint8Data = data.toUInt8Array()
            //ws.send(uint8Data)
            //Find target room number array
            let targetUser = allSockets[id]
            
        
            for i in targetUser! {
                if i.id != socketConnection.id {
                    let uint8Data = data.toUInt8Array()
                    i.ws.send(uint8Data)
                }
            }
            
            print("Returned data!")
        }
        
        //接受ping
        ws.onPing { ws in
            // 这里已经接收到ping
        }
        /*
         ws.onClose.whenComplete { _ in
         }
         */
    }
}

extension Data {
    func toUInt8Array() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var byteArray = [UInt8](repeating: 0, count: count)
        self.copyBytes(to: &byteArray, count:count)
        return byteArray
    }
}

// 这俩类用于读写发送和接受的信息
struct SocketFromMessage: Codable {
    var target: Int
    var source: Int
    var msg: String
}

struct SocketToMessage: Codable {
    var source: Int
    var msg: String
}
