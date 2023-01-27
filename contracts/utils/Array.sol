// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.0;

library Array  {

    // UInt32

    function reset(
        uint32[] storage t_
        
    ) internal {
        uint len = t_.length;
        while (len-->0)
            t_.pop();
    }
    
    function sum(
        uint32[] storage t_
    ) internal view returns (uint32 sum_) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             sum_ += t_[i];
    }


    function insert(
        uint32[] storage t_,
        uint32 index_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return false;
        t_.push(index_);
        return true;
    }
    function exist(uint32[] storage t_, uint32 index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(uint32[] memory t_, uint32 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(uint32 i_) pure internal returns (uint32[] memory out_) {
        out_ = new uint32[](1);
        out_[0]=i_; 
    }

    function remove(uint32[] storage t_, uint32 index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;
    }

    //Uint64

    function reset(
        uint64[] storage t_
        
    ) internal {
        uint len = t_.length;
        while (len-->0)
            t_.pop();
    }

    function sum(
        uint64[] storage t_
    ) internal view returns (uint64 sum_) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             sum_ += t_[i];
    }

    function insert(
        uint64[] storage t_,
        uint64 index_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return false;
        t_.push(index_);
        return true;
    }
    function exist(uint64[] storage t_, uint64 index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(uint64[] memory t_, uint64 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(uint64 i_) pure internal returns (uint64[] memory out_) {
        out_ = new uint64[](1);
        out_[0]=i_; 
    }

    function remove(uint64[] storage t_, uint64 index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;
    }

    

    function reset(
        uint256[] storage t_
        
    ) internal {
        uint len = t_.length;
        while (len-->0)
            t_.pop();
    }

    function sum(
        uint256[] storage t_
    ) internal view returns (uint256 sum_) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             sum_ += t_[i];
    }

    function insert(
        uint256[] storage t_,
        uint256 index_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return false;
        t_.push(index_);
        return true;
    }
    function exist(uint256[] storage t_, uint256 index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(uint256[] memory t_, uint256 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(uint256 i_) pure internal returns (uint256[] memory out_) {
        out_ = new uint256[](1);
        out_[0]=i_; 
    }

    function remove(uint256[] storage t_, uint256 index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;
    }




    function reset(
        address[] storage t_
        
    ) internal {
        uint len = t_.length;
        while (len-->0)
            t_.pop();
    }

    function insert(
        address[] storage t_,
        address index_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==index_)
                return false;
        t_.push(index_);
        return true;
    }
    function cexist(address[] calldata t_, address index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function exist(address[] storage t_, address index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(address[] memory t_, address index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(address i_) pure internal returns (address[] memory out_) {
        out_ = new address[](1);
        out_[0]=i_; 
    }

    function remove(address[] storage t_, address index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;      
    }
    function insert(
        bytes4[] storage t_,
        bytes4 index_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==index_)
                return false;
        t_.push(index_);
        return true;
    }
    function exist(bytes4[] storage t_, bytes4 index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
           if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(bytes4[] memory t_, bytes4 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
           if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(bytes4 i_) pure internal returns (bytes4[] memory out_) {
        out_ = new bytes4[](1);
        out_[0]=i_; 
    }

    function remove(bytes4[] storage t_, bytes4 index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;
    }    
    function push(string[] memory t_, string memory s_)
        internal pure
    returns (string[] memory out_)
    {
        uint len = t_.length;
        out_ = new string[](len+1);
        for (uint i;i<len;i++)
            out_[i]=t_[i];
        out_[len] = s_;
    }
    function push(bytes32[] memory t_, bytes32 s_)
        internal pure
    returns (bytes32[] memory out_)
    {
        uint len = t_.length;
        out_ = new bytes32[](len+1);
        for (uint i;i<len;i++)
            out_[i]=t_[i];
        out_[len] = s_;
    }
    function insert(
        bytes32[] storage t_,
        bytes32 s_
    ) internal returns (bool) {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==s_)
                return false;
        t_.push(s_);
        return true;
    }
    function remove(bytes32[] storage t_, bytes32 index_)
        internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
            if (t_[i]==index_)
            {
                if (i<len-1)
                    t_[i] = t_[len-1];
                t_.pop();
                return true;
            }
        return false;      
    }

    function cexist(bytes32[] calldata t_, bytes32 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function exist(bytes32[] storage t_, bytes32 index_)
        view internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function mexist(bytes32[] memory t_, bytes32 index_)
        pure internal
    returns (bool)
    {
        uint len = t_.length;
        for (uint i;i<len;i++)
             if (t_[i]==index_)
                return true;
        return false;
    }
    function munique(bytes32 i_) pure internal returns (bytes32[] memory out_) {
        out_ = new bytes32[](1);
        out_[0]=i_; 
    }
    function addtail(bytes32[] memory in_, bytes32  s_)
        internal
        pure
        returns (bytes32[] memory out_)
    {
        /*for (uint256 i; i < sols_.length; i++) {
            if (sols_[i].orderid == sol_.orderid)
            {
                sols_[i].qty += sol_.qty;
                return sols_;
            }
        }*/
        bytes32[] memory set = new bytes32[](1);
        set[0] = s_;
        return combine(in_, set);
    }
    function addfront(bytes32[] memory in_, bytes32  s_)
        internal
        pure
        returns (bytes32[] memory out_)
    {
        /*for (uint256 i; i < sols_.length; i++) {
            if (sols_[i].orderid == sol_.orderid)
            {
                sols_[i].qty += sol_.qty;
                return sols_;
            }
        }*/
        bytes32[] memory set = new bytes32[](1);
        set[0] = s_;
        return combine(set,in_);
    }
    function combine(bytes32[] memory set1_, bytes32[] memory set2_)
        internal
        pure
        returns (bytes32[] memory out_)
    {
        uint256 _set1len = set1_.length;
        uint256 _set2len = set2_.length;

        out_ = new bytes32[](_set1len + _set2len);

        for (uint256 i; i < _set1len; i++) {
            out_[i] = set1_[i];
        }
        for (uint256 i; i < _set2len; i++) {
            out_[_set1len + i] = set2_[i];
        }
    }

    function pack(bytes32[] memory t_)
        pure internal
    returns (bytes memory out_)
    {
         uint len = t_.length*32;
       out_ = new bytes(len);
        for (uint i=32;i<=len;i+=32)
            assembly {
                mstore(add(out_, i), add(t_, i)) 
                }            
    }
}