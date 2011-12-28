CP=cp --no-dereference
RM=rm -rf
MKDIR=mkdir -p
ECHO=echo -e

BUILD=build
WQMAKE=../../wqmake
INSTALL=install
SRC=src

EXT_LIB_PATH=src/ext/lib
EXT_INC_PATH=src/ext/inc
INST_LIB_PATH=lib

STBSETTINGS_PRO=stbsettings.pro
STBSETTINGS_SRC_PATH=./src/stbsettings
STBSETTINGS_TARGET=libstbsettings.so
STBSETTINGS_INC=stbsettings.h
STBSETTINGS_INST_BUILD_DIR=../ext/lib/
STBSETTINGS_INST_HEADER_DIR=../ext/inc/

STBMAIN_PRO=stbmain.pro
STBMAIN_SRC_PATH=./src/stbmain
STBMAIN_TARGET=stbmain

WEATHER_PRO=weather.pro
WEATHER_SRC_PATH=./src/weather
WEATHER_TARGET=libweather.so
WEATHER_PATH=weather

MEDIAPLAYER_PRO=mediaplayer.pro
MEDIAPLAYER_SRC_PATH=./src/mediaplayer
MEDIAPLAYER_TARGET=libmediaplayer.so
MEDIAPLAYER_PATH=mediaplayer

IPTVPLAYER_PRO=iptvplayer.pro
IPTVPLAYER_SRC_PATH=./src/iptvplayer
IPTVPLAYER_TARGET=libiptvplayer.so
IPTVPLAYER_PATH=iptvplayer

SETTINGS_PRO=settings.pro
SETTINGS_SRC_PATH=./src/settings
SETTINGS_TARGET=libsettings.so
SETTINGS_PATH=settings

MINITUBE_PRO=minitube.pro
MINITUBE_SRC_PATH=./src/minitube
MINITUBE_TARGET=libminitube.so
MINITUBE_PATH=minitube

CPD_PRO=cpd.pro
CPD_SRC_PATH=./src/cpd
CPD_TARGET=cpd

.PHONY: all clean install
.PHONY: dirs common stbapi qtstbapi stbsettings
.PHONY: stbmain cpd settings weather mediaplayer iptvplayer minitube

all: dirs common stbapi qtstbapi stbsettings stbmain weather mediaplayer iptvplayer settings minitube cpd
	$(ECHO) "\n\n\nDONE\n"

dirs:
	$(MKDIR) $(INSTALL) $(SRC)

clean:
	$(RM) $(INSTALL)
	$(RM) $(SRC)

common: dirs
	cd $(SRC);git clone git@192.168.24.14:common.git

stbapi: dirs
	cd $(SRC);hg clone http://192.168.24.14:9000/stbapi;cd stbapi/src;make -j8 install
	$(MKDIR) $(EXT_LIB_PATH)
	$(CP) $(SRC)/stbapi/lib/* $(EXT_LIB_PATH)

qtstbapi: dirs common stbapi
	cd $(SRC);git clone git@192.168.24.14:qtstbapi.git;cd qtstbapi;$(WQMAKE) player.pro;make -j8
	$(CP) src/qtstbapi/libqtstbapi.so* $(EXT_LIB_PATH)
	$(MKDIR) $(EXT_INC_PATH)
	$(CP) src/qtstbapi/*.h $(EXT_INC_PATH)

stbsettings: dirs common stbapi
	$(ECHO) "\n\n\nBuilding stbsettings library\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:stbsettings.git
	$(MKDIR) $(EXT_LIB_PATH)
	$(MKDIR) $(EXT_INC_PATH)
	$(RM) $(EXT_LIB_PATH)/$(STBSETTINGS_TARGET)*
	$(RM) $(EXT_INC_PATH)/$(STBSETTINGS_INC)
	cd $(STBSETTINGS_SRC_PATH);$(WQMAKE) $(STBSETTINGS_PRO);make all -j8
	$(CP) $(STBSETTINGS_SRC_PATH)/$(STBSETTINGS_TARGET)* $(EXT_LIB_PATH)
	$(CP) $(STBSETTINGS_SRC_PATH)/$(STBSETTINGS_INC) $(EXT_INC_PATH)

stbmain: dirs common stbsettings qtstbapi
	$(ECHO) "\n\n\nbuilding stbmain!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:stbmain.git
	cd $(STBMAIN_SRC_PATH); $(WQMAKE) $(STBMAIN_PRO);make all -j8

weather: dirs common
	$(ECHO) "\n\n\nbuilding weather!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:weather.git
	cd $(WEATHER_SRC_PATH); $(WQMAKE) $(WEATHER_PRO);make all -j8

mediaplayer: dirs common qtstbapi stbsettings
	$(ECHO) "\n\n\nbuilding mediaplayer!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:mediaplayer.git
	cd $(MEDIAPLAYER_SRC_PATH); $(WQMAKE) $(MEDIAPLAYER_PRO);make all -j8

iptvplayer: dirs common qtstbapi stbsettings
	$(ECHO) "\n\n\nbuilding iptvplayer!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:iptvplayer.git
	cd $(IPTVPLAYER_SRC_PATH); $(WQMAKE) $(IPTVPLAYER_PRO);make all -j8

settings: dirs common stbsettings qtstbapi
	$(ECHO) "\n\n\nbuilding settings!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:settings.git
	cd $(SETTINGS_SRC_PATH); $(WQMAKE) $(SETTINGS_PRO);make all -j8

minitube: dirs common qtstbapi stbsettings
	$(ECHO) "\n\n\nbuilding minitube!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:minitube.git
	cd $(MINITUBE_SRC_PATH); $(WQMAKE) $(MINITUBE_PRO);make all -j8

cpd: dirs common
	$(ECHO) "\n\n\nbuilding copy daemon!!!\n\n\n"
	cd $(SRC);git clone git@192.168.24.14:cpd.git
	cd $(CPD_SRC_PATH); $(WQMAKE) $(CPD_PRO);make all -j8

install: all
	$(MKDIR) $(INSTALL)/$(INST_LIB_PATH)
	$(CP) $(EXT_LIB_PATH)/* $(INSTALL)/$(INST_LIB_PATH)
	$(CP) $(STBMAIN_SRC_PATH)/$(STBMAIN_TARGET) $(INSTALL)
	$(MKDIR) $(INSTALL)/$(WEATHER_PATH)
	$(CP) $(WEATHER_SRC_PATH)/$(WEATHER_TARGET) $(INSTALL)/$(WEATHER_PATH)
	$(MKDIR) $(INSTALL)/$(MEDIAPLAYER_PATH)
	$(CP) $(MEDIAPLAYER_SRC_PATH)/$(MEDIAPLAYER_TARGET) $(INSTALL)/$(MEDIAPLAYER_PATH)
	$(MKDIR) $(INSTALL)/$(IPTVPLAYER_PATH)
	$(CP) $(IPTVPLAYER_SRC_PATH)/$(IPTVPLAYER_TARGET) $(INSTALL)/$(IPTVPLAYER_PATH)
	$(MKDIR) $(INSTALL)/$(SETTINGS_PATH)
	$(CP) $(SETTINGS_SRC_PATH)/$(SETTINGS_TARGET) $(INSTALL)/$(SETTINGS_PATH)
	$(CP) $(CPD_SRC_PATH)/$(CPD_TARGET) $(INSTALL)
	$(MKDIR) $(INSTALL)/$(MINITUBE_PATH)
	$(CP) $(MINITUBE_SRC_PATH)/$(MINITUBE_TARGET) $(INSTALL)/$(MINITUBE_PATH)

