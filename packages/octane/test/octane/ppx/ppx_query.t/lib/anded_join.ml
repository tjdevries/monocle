let%query (module ChatsForUserByName) =
  "SELECT Chat.id, Account.name, Chat.message\n\
  \    FROM Chat INNER JOIN Account ON Account.id = Chat.user_id\n\
  \    WHERE Account.name = $1 AND Account.id = $2"
;;
