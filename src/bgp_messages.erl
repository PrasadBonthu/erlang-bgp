%%%=====================================================================================================================
%%% Copyright (c) 2009, Bruno Rijsman
%%%
%%% Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby 
%%% granted, provided that the above copyright notice and this permission notice appear in all copies.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL 
%%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, 
%%% INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
%%% AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR 
%%% PERFORMANCE OF THIS SOFTWARE.
%%%=====================================================================================================================

%% @author Bruno Rijsman
%% @copyright 2009 Bruno Rijsman
%% @doc The message module provides functions for the manipulation of BGP messages.
%%

-module(bgp_messages).
-author('Bruno Rijsman').

-export([encode_open/1,
         encode_update/1,
         encode_keep_alive/0,
         encode_notification/1]).

-include("bgp_messages.hrl").
-include("bgp_constants.hrl").
-include_lib("eunit/include/eunit.hrl").            %% TODO: write unit tests

%%----------------------------------------------------------------------------------------------------------------------

encode_open(Open)
  when is_record(Open, bgp_open) ->
    Length = 29,                                
    OptionsLength = 0,                          %% TODO: Need to support options.
    FixedPart = <<16#ffffffffffffffffffffffffffffffff:128,
                  Length:16,
                  ?BGP_MESSAGE_TYPE_OPEN:8,
                  (Open#bgp_open.version):8,
                  (Open#bgp_open.my_as):16,
                  (Open#bgp_open.hold_time):16,
                  (ip_to_num(Open#bgp_open.identifier)):32,
                  OptionsLength:8>>,
    FixedPart.

%%----------------------------------------------------------------------------------------------------------------------

%% TODO: Finish this.
%%
encode_update(Update)
  when is_record(Update, bgp_update) ->
    Length = 19,
    FixedPart = <<16#ffffffffffffffffffffffffffffffff:128,
                  Length:16,
                  ?BGP_MESSAGE_TYPE_UPDATE:8>>,
    FixedPart.

%%----------------------------------------------------------------------------------------------------------------------

encode_keep_alive() ->
    <<16#ffffffffffffffffffffffffffffffff:128, 19:16, ?BGP_MESSAGE_TYPE_KEEP_ALIVE:8>>.

%%----------------------------------------------------------------------------------------------------------------------

encode_notification(Notification)
  when is_record(Notification, bgp_notification) ->
    Length = 21 + length(Notification#bgp_notification.data),
    <<16#ffffffffffffffffffffffffffffffff:128,
      Length:16,
      ?BGP_MESSAGE_TYPE_NOTIFICATION:8,
      (Notification#bgp_notification.error_code):8,
      (Notification#bgp_notification.error_sub_code):8,
      (Notification#bgp_notification.data)/binary>>.

%%----------------------------------------------------------------------------------------------------------------------
%spec ip_to_num(ipv4_address(), prefix_len()) -> uint32().
ip_to_num(Ip, Len) ->
  ip_to_num(Ip) bsr (32 - Len).

%%spec ip_to_num(ipv4_address()) -> uint32().
ip_to_num({B1, B2, B3, B4}) ->
  (B1 bsl 24) bor (B2 bsl 16) bor (B3 bsl 8) bor B4.

%%spec num_to_ip(uint32(), prefix_len()) -> ipv4_address().
num_to_ip(Num, Len) ->
  num_to_ip(Num bsl (32 - Len)).

%%spec num_to_ip(uint32()) -> ipv4_address().
num_to_ip(Num) ->
  B1 = (Num band 16#ff000000) bsr 24,
  B2 = (Num band 16#00ff0000) bsr 16,
  B3 = (Num band 16#0000ff00) bsr 8,
  B4 = (Num band 16#000000ff),
  {B1, B2, B3, B4}.


