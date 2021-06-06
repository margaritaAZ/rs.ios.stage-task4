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
        guard !(stationUsers?.contains(user) ?? false) else{
            return
        }
        if stationUsers != nil {
            stationUsers?.append(user)
        } else {
            stationUsers = [user]
        }
    }
    
    func remove(user: User) {
        guard let sUsers = stationUsers else {
            return
        }
        var userIndex: Int?
        for (index,stationUser) in sUsers.enumerated() {
            if stationUser.id == user.id {
                userIndex = index
                break
            }
        }
        if let index = userIndex {
            stationUsers?.remove(at: index)
        }
    }
    
    func addCallToCallsList(from: User, to: User, callStatus: CallStatus) -> CallID {
        let call = Call(id: UUID(), incomingUser: from, outgoingUser: to, status: callStatus)
        if callsList != nil {
            callsList?.append(call)
        } else {
            callsList = [call]
        }
        return call.id
    }
    
    func changeCallStatus(call: Call, index: Int, newStatus: CallStatus) -> CallID? {
        let changedCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: newStatus)
        callsList?.remove(at: index)
        callsList?.insert(changedCall, at: index)
        
        if newStatus == .ended(reason: .error) {
            return nil
        }
        return call.id
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
                return addCallToCallsList(from: user1, to: user2, callStatus: .ended(reason: .error))
            }
            
            if let calls = callsList {
                for call in calls{
                    if ((call.outgoingUser.id == user2.id || call.incomingUser.id == user2.id) && call.status == .talk) {
                        return addCallToCallsList(from: user1, to: user2, callStatus: .ended(reason: .userBusy))
                    }
                }
            }
            return addCallToCallsList(from: user1, to: user2, callStatus: .calling)
            
        case .answer(let user2):
            guard let calls = callsList else {
                return nil
            }
            
            for (index, call) in calls.enumerated() {
                if (call.outgoingUser.id == user2.id && call.status == .calling) {
                    if (stationUsers?.contains(user2) ?? false) {
                        return changeCallStatus(call: call, index: index, newStatus: .talk)
                    } else {
                        return changeCallStatus(call: call, index: index, newStatus: .ended(reason: .error))
                    }
                }
            }
            return nil
            
        case .end(let user):
            guard let calls = callsList else {
                return nil
            }
            
            for (index, call) in calls.enumerated() {
                if ((call.outgoingUser.id == user.id || call.incomingUser.id == user.id) &&
                        call.status == .talk) {
                    return changeCallStatus(call: call, index: index, newStatus: .ended(reason: .end))
                }
                if (call.outgoingUser.id == user.id && call.status == .calling) {
                    return changeCallStatus(call: call, index: index, newStatus: .ended(reason: .cancel))
                }
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

