CC=clang
FRAMEWORKS=-framework Cocoa -framework DFRFoundation -F /System/Library/PrivateFrameworks
CFLAGS=-mmacosx-version-min=10.12 -x objective-c
LDFLAGS=-fobjc-link-runtime $(FRAMEWORKS)
SOURCES=touchhorn.m
OBJECTS=touchhorn.o
OUT=touchhorn
BUNDLE=touchhorn.app

all: $(SOURCES) $(OUT)
	@mkdir -p "$(BUNDLE)/Contents/MacOS"
	@cp "$(OUT)" "$(BUNDLE)/Contents/MacOS/"
	@cp Info.plist "$(BUNDLE)/Contents"

run: all kill
	@open "$(BUNDLE)"

install: all
	@cp $(OUT) /usr/local/bin/$(OUT)
	@cp airhorn.aiff ~/Library/Sounds/airhorn.aiff
	@cp Launch.plist ~/Library/LaunchAgents/airhorn.service.plist
	@launchctl load ~/Library/LaunchAgents/airhorn.service.plist

uninstall: clean
	@launchctl unload ~/Library/LaunchAgents/airhorn.service.plist
	@rm -f /usr/local/bin/$(OUT)
	@rm -f ~/Library/Sounds/airhorn.aiff
	@rm -f ~/Library/LaunchAgents/airhorn.service.plist

$(OUT): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $(OUT)

.m.o:
	$(CC) -c $(CFLAGS) $< -o $@

kill:
	@pkill $(OUT) ; true

clean:
	@rm -f *~ $(OUT) *.o
	@rm -rf "$(BUNDLE)"
