pragma solidity ^0.4.10;
contract StrToBytes32Array
{
    function StrToBytes32Array(string p_str) returns(bytes32[]){
        bytes  memory lbts_para;  //the result of convert p_str to bytes
        uint li_paralength;   //lbts_para's length
        string memory ls_new; //the result of convert ont bytes32 to string
        bytes32 lbt_row;      // the new bytes32 data  
        bytes32[] lbt_result32;    //the return bytes32 array     
        uint li_rowcount; // bytes32 array's length
        uint li_temp;  
        uint li_sum; //the total byte32 array's bytes amount
        uint li_colidx;  //the new column's index
        uint li_resultlength ; // the result bytes32 array's length

        lbts_para = bytes(p_str); //ex:'1234' = 0x31323334
        li_paralength = lbts_para.length;  //ex: 4 
        bytes memory lbts_new = new bytes(32); //for store to arrays32 array
        lbt_result32.length=0; //ininial the array32 array
        if (li_paralength <= 32 ){  //if actul data length is less equal than 32,use assemble method
            assembly {
               lbt_row := mload(add(p_str, 32))
            }
            lbt_result32.length = 1;
            lbt_result32[0] = lbt_row;
        } else {
            //li_rowcount :calculate the bytes32 array's length
            li_rowcount = li_paralength/32;
            li_temp = li_paralength%32;
            if (li_temp > 0 )
                li_rowcount = li_rowcount +1;
            //li_sum :the total bytes amount of bytes32 array
            li_sum = li_rowcount *32;
            li_colidx = 0;
            for (uint p = 1;p<= li_sum;p++){
                //decide whether to add a new row
                li_temp = p%32;  //if equal 0,add a new row
                if (li_temp == 0 ){
                    if (p > li_paralength) 
                        lbts_new[li_colidx] = 0x0;
                    else
                        lbts_new[li_colidx] = lbts_para[p - 1];
                    li_colidx = 0;
                    ls_new = string(lbts_new);
                    assembly {
                        lbt_row := mload(add(ls_new, 32))
                    }
                    li_resultlength = lbt_result32.length ;
                    li_resultlength = li_resultlength +1;
                    lbt_result32.length = li_resultlength;
                    lbt_result32[li_resultlength - 1] = lbt_row;
                }else {
                    if (p > li_paralength) 
                        lbts_new[li_colidx] = 0x0;
                    else
                        lbts_new[li_colidx] = lbts_para[p - 1];
                    li_colidx = li_colidx +1;
                }

            }

        }

        return lbt_result32;

    }
}