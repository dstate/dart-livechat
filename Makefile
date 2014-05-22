NAME					=	livechat

DARTDIR					=	client/
JSDIR					=	./
JSMISCDIR				=	client/build/

DART2JS					=	dart2js
MKDIR					=	mkdir
MV						=	mv
RM						=	rm -f

DARTLIST				=	main.dart
DART					=	$(addprefix $(DARTDIR), $(DARTLIST))
JS						=	$(patsubst $(DARTDIR)%.dart, $(JSDIR)%.dart.js, $(DART))
JSMISC					=	$(patsubst $(DARTDIR)%.dart, $(JSMISCDIR)%.dart.js.deps, $(DART))
JSMISC					+=	$(patsubst $(DARTDIR)%.dart, $(JSMISCDIR)%.dart.js.map, $(DART))
JSMISC					+=	$(patsubst $(DARTDIR)%.dart, $(JSMISCDIR)%.dart.precompiled.js, $(DART))

################################################################################

all						:	$(JS)

run						:
							python server/main.py

$(JS)					:	| $(JSMISCDIR) $(JSDIR) $(DARTDIR)

$(JSMISCDIR)			:
							$(MKDIR) -p $(JSMISCDIR)

$(JSDIR)				:
							$(MKDIR) -p $(JSDIR)

$(DARTDIR)				:
							$(MKDIR) -p $(DARTDIR)

$(JSDIR)%.dart.js		:	$(DARTDIR)%.dart
							$(DART2JS) -o $@ $<
							$(MV) $(JSDIR)$*.dart.js.deps $(JSMISCDIR)
							$(MV) $(JSDIR)$*.dart.js.map $(JSMISCDIR)
							$(MV) $(JSDIR)$*.dart.precompiled.js $(JSMISCDIR)

clean					:
							$(RM) $(JSMISC)

fclean					:	clean
							$(RM) $(JS)

re						:	fclean all

.PHONY					:	clean fclean re
