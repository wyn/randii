type digits = | Two | Four

module type CTR = sig
  type el
  type t
  val of_array : el array -> t
  val to_array : t -> el array
  val to_string_array : t -> string array
  val copy : t -> t
  val succ : t -> t
  val pred : t -> t
  val digits : t -> digits
  val data : t -> el array
end

module Make_ctr (U:Threefry.T) : (CTR with type el := U.t) = struct
  type el = U.t
  type t = {
    data: el array;
    digits: digits
  }

  let of_array data =
    match Array.length data with
    | 0 -> raise (Invalid_argument "No data")
    | 1 -> {data=Array.(append (copy data) [| U.zero |]); digits=Two}
    | 2 -> {data=Array.copy data; digits=Two}
    | 3 -> {data=Array.(append (copy data) [| U.zero |]); digits=Four}
    | 4 -> {data=Array.copy data; digits=Four}
    | _ -> raise (Invalid_argument "Too large")
  let to_array {data; _} = Array.copy data
  let to_string_array t = to_array t |> Array.map U.to_string

  let copy {data; digits} = {data=Array.copy data; digits}

  let rec aux_i digit f sentinal {data; digits} =
    let n = Array.length data in
    if digit == n then () else (
      let d = f data.(digit) in
      match (U.equal sentinal d) with
      | false -> data.(digit) <- d;
      | true -> data.(digit) <- d; aux_i (digit+1) f sentinal {data; digits}
    )

  let succ t = aux_i 0 U.succ U.zero t; t
  let pred t = aux_i 0 U.pred U.max_int t; t

  let digits t = t.digits
  let data t = t.data
end
