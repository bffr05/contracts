// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

enum Unauthorized_Reason {
    Unkwown,
    onlyThis,
    onlyReentrancy,
    onlyOperator,
    onlyCreator,
    onlyOwner,
    onlyApproved,
    onlyTrusted,
    onlyReferral
}
error Unauthorized(Unauthorized_Reason reason);

enum Unsupported_Reason {
    Unkwown,
    TokenType,
    MessageType,
    Existent,
    NonExistent
}
error Unsupported(Unsupported_Reason reason);

error ZeroAddress();
error BalanceExceeded();
error AllowanceExceeded();
error Paused();
error Assert();
error Invalid();
error Failed();