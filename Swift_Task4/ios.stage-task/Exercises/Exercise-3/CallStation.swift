import Foundation

final class CallStation {
    var stationUsers: [User]?
    var callsList: [Call]?
    
}

extension CallStation: Station {
    func users() -> [User] {
        return self.stationUsers ?? []
    }
    
    func add(user: User) {

        guard !(self.stationUsers?.contains(user) ?? false) else{
            return
        }
        
        if self.stationUsers != nil {
            self.stationUsers?.append(user)
        } else {
            self.stationUsers = [user]
        }
    }
    
    func remove(user: User) {
        guard let users = stationUsers else {
            return
        }
        var userIndex: Int?
        for (index,stationUser) in users.enumerated() {
            if stationUser.id == user.id {
                userIndex = index
            }
        }
        
        if let index = userIndex {
            stationUsers?.remove(at: index)
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
        case .start(let user1, let user2):
            guard let users = stationUsers else {
                return nil
            }
            guard users.contains(user1) else {
                return nil
            }
            guard users.contains(user2) else {
                let call = Call(id: UUID(), incomingUser: user1, outgoingUser: user2, status: .ended(reason: .error))
                if callsList != nil {
                    callsList?.append(call)
                }
                callsList = [call]
                return call.id
            }
            
            if let calls = callsList {
                for call in calls{
                    // добавить условие наоборот
                    if (call.outgoingUser.id == user2.id && call.incomingUser.id != user1.id && call.status == .talk) {
                        let call = Call(id: UUID(), incomingUser: user1, outgoingUser: user2, status: .ended(reason: .userBusy))
                        callsList?.append(call)
                        return call.id
                    }
                    let call = Call(id: UUID(), incomingUser: user1, outgoingUser: user2, status: .calling)
                    callsList?.append(call)
                    return call.id
                }
            }
            let call = Call(id: UUID(), incomingUser: user1, outgoingUser: user2, status: .calling)
            self.callsList = [call]
            return call.id
            
        case .answer(let user2):
            guard let calls = callsList else {
                return nil
            }
            
           // var callIndex: Int?
            var callAnswer: Call?
            for (index, call) in calls.enumerated() {
                if (call.outgoingUser.id == user2.id && call.status == .calling) {
                   // callIndex = index
                    if (stationUsers?.contains(user2) ?? false) {
                        callAnswer = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .talk)
                        self.callsList?.remove(at: index)
                        self.callsList?.insert(callAnswer!, at: index)
                        return callAnswer?.id
                    } else {
                        callAnswer = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .error))
                        self.callsList?.remove(at: index)
                        self.callsList?.insert(callAnswer!, at: index)
                        return nil
                    }
                }
            }
            return nil
            
        case .end(let user):
            guard let calls = callsList else {
                return nil
            }
            
            var callIndex: Int?
            var callTalking: Call?
            for (index, call) in calls.enumerated() {
                if ((call.outgoingUser.id == user.id || call.incomingUser.id == user.id) &&
                        call.status == .talk) {
                    callIndex = index
                    callTalking = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .end))
                    break
                }
                if (call.outgoingUser.id == user.id && call.status == .calling) {
                    callIndex = index
                    callTalking = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .cancel))
                    break
                }
            }
            if callIndex != nil {
                self.callsList?.remove(at: callIndex!)
                self.callsList?.insert(callTalking!, at: callIndex!)
                return callTalking?.id
            }
            return nil
        }
    }
    
    func calls() -> [Call] {
        return self.callsList ?? []
    }
    
    func calls(user: User) -> [Call] {
        guard let calls = callsList else {
            return []
        }
        
        var userCalls: [Call] = []
        for call in calls {
            if call.outgoingUser.id == user.id || call.incomingUser.id == user.id {
                userCalls.append(call)
            }
        }
        return userCalls
    }
    
    func call(id: CallID) -> Call? {
        guard let calls = callsList else {
            return nil
        }
        
        for call in calls {
            if call.id == id {
                return call
            }
        }
        return nil
    }
    
    func currentCall(user: User) -> Call? {
        guard let calls = callsList else {
            return nil
        }
        
        for call in calls {
            if ((call.incomingUser.id == user.id || call.outgoingUser.id == user.id) && call.status == .calling) {
                return call
            }
        }
        
        return nil
    }
}

