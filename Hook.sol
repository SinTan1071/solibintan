contract Function_hook_example {
    
    function Function_hook_example() {
        owner = msg.sender;
    }
    
    modifier isOwner {
        if (msg.sender == owner) {
            _
        }
    }
    
    //do a hook after normal exeuction.
    modifier post_hook {
        _
        if (post_function_hooks[msg.sig] != 0x0) {
            post_function_hooks[msg.sig].call(msg.data);
        }
    }
    
    //do a hook before normal execution.
    modifier pre_hook {
        if (pre_function_hooks[msg.sig] != 0x0) {
            pre_function_hooks[msg.sig].call(msg.data);
        }
        _
    }
    
    function doSomething(bytes32 _text) pre_hook post_hook {
        //do basic stuff here.
    }
    
    
    function changeOwner(address _newOwner) isOwner {
        owner = _newOwner;
    }
    
    function changeHook(bytes32 _type, bytes4 _functionSig, address _contract) isOwner {
        if (_type == "pre") {
            pre_function_hooks[_functionSig] = _contract;
        } else if (_type == "post") {
            post_function_hooks[_functionSig] = _contract;
        }
    }
    
    address public owner;
    mapping (bytes4 => address) pre_function_hooks;
    mapping (bytes4 => address) post_function_hooks;
}

contract otherContract {
    
    //called from hook example.
    function doSomething(bytes32 _text) {
        //do extra stuff here. Use _text or not.
        //ie, notify etherex of a deposit.
    }
}