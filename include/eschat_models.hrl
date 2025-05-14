-define(NOW_SEC, erlang:system_time(second)).
-define(CACHE_TTL, 10000).

-record(user, {
  id,
  login,
  password
}).

-record(session, {
  sid,
  user_id
}).

-record(chatMessage, {
  id,
  chat_id,
  user_id,
  reply_for_id,
  message
}).

-record(chat, {
  id,
  name
}).

-record(chatMember,{
  chat_id,
  user_id,
  is_owner = false
}).
