let%query (module AuthorAndContent) =
  {| SELECT Account.name, Post.content FROM Post INNER JOIN Account ON Account.id = Post.author |}
;;

(* let%query (module AuthorAndContent) = *)
(*   {| SELECT Account.name, Post.content FROM Post INNER JOIN Account ON Account.id = Post.authorasdf |} *)
(* ;; *)
