type transfer_param is record
amount : int;
answer : string;
addr : address;
end

type action is
| Vote of transfer_param
| Reset of bool

type storage is record
owner : address;
has_voted : bool;
answer_map : map(string, int);
user : map(address, bool);
status: bool;
nb_vote : int;
end


function reset (const s : storage) : storage is
block { 
  s.status := True    
  } with s

function vote (const params : transfer_param; const s : storage) : storage is
block {
  if Tezos.source =/= s.owner and s.status = True
    then block{  
  const sum : option(int) = s.answer_map[params.answer]; 
  const target : int = case sum of
  | None -> 0
  | Some(n) -> n
  end;
  s.answer_map[params.answer] := target + 1;
  s.nb_vote := s.nb_vote + 1 ;  
  s.user[params.addr] := False;
    }
  else block {
    failwith ("Access denied.") 
  }
} with s



function main (const p : action ; const s : storage) :
  (list(operation) * storage) is
  block {     
    const newStorage : storage = case p of
    | Reset(n) -> reset(s)
    | Vote(n) -> vote(n,s)
  end;
  if s.nb_vote < 10
    then block {
      s.status := True;
  }
    else block {
      s.status := False;
  }
  } with ((nil : list(operation)), newStorage)
