# /* outside click detector */
# (function($){
#     $.fn.outside = function(ename, cb){
#         return this.each(function(){
#             var $this = $(this),
#                 self = this;
# 
#             $(document).bind(ename, function tempo(e){
#                 if(e.target !== self && !$.contains(self, e.target)){
#                     cb.apply(self, [e]);
#                     if(!self.parentNode) $(document.body).unbind(ename, tempo);
#                 }
#             });
#         });
#     };
# }(jQuery));

# This idea is to use a generic array for
# variables & function (BF.var & BF.fn) to
# have avoid using globals all over the website
# This code need to be somewhere else.
# BF = {} if !BF?
# BF.fn = {} if !BF.fn?
# 
# BF.fn.outside = (ename, cb) ->
#   @each ->
#     $this = $(this)
#     self = this
#     $(document).bind ename, tempo = (e) ->
#       if e.target isnt self and not $.contains(self, e.target)
#         cb.apply self, [e]
#         $(document.body).unbind ename, tempo  unless self.parentNode