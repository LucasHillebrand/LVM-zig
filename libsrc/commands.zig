pub const noop = 0; // no operatiom

pub const add = 1; // add
pub const sub = 2; // sub

pub const sma = 3; // set mem address
pub const smv = 4; // set mem value
pub const gmv = 5; // get mem value
pub const gms = 6; // get mem size

pub const jmp = 7; // jump
pub const jiz = 8; // jump if zero
pub const jnz = 9; // jump ifnot zero

pub const nt = 10; // new thread
pub const kt = 11; // kill thread

pub const srb = 12; // set register byte
pub const spc = 13; // save programm counter

pub const hlt = 255; // halt
