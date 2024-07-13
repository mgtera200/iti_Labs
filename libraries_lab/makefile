# Compiler
CC = arm-cortexa9_neon-linux-musleabihf-gcc

# Compilation flags

INCS=-I ./Includes

# Directories
SRC_DIR = src
OBJ_DIR = obj
APP_DIR = app
DYNAMIC_LIB_DIR = dynamic_lib
STATIC_LIB_DIR = static_lib

# File names
APP_SRC = main.c
APP_NAME = myapp

DYNAMIC_LIB_SRC = $(wildcard $(SRC_DIR)/*.c)
DYNAMIC_LIB_NAME = libdynamic
DYNAMIC_LIB_BASE_NAME = $(patsubst lib%, %, $(DYNAMIC_LIB_NAME))

OBJ = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(DYNAMIC_LIB_SRC))


STATIC_LIB_SRC = $(DYNAMIC_LIB_SRC)
STATIC_LIB_NAME = libstatic
STATIC_LIB_BASE_NAME = $(patsubst lib%, %, $(STATIC_LIB_NAME))


# Paths
PATH += :/home/eng-tera/iti/x-tools/arm-cortexa9_neon-linux-musleabihf/bin

# Targets
all: dynamic_app static_app

# Rule to compile object files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c

	@if [ ! -d $(dir $@) ];then \
	mkdir -p $(dir $@); \
	echo "[Eng.TERA] Directory $(dir $@) Created successfully"; \
	fi 
	@$(CC)  -c $< -o $@
	@echo "[Eng.TERA] $@ Created successfully"

# Rule to create dynamic library
$(DYNAMIC_LIB_DIR)/$(DYNAMIC_LIB_NAME).so: $(OBJ)
	@mkdir -p $(DYNAMIC_LIB_DIR)
	@$(CC) -shared $^ -o $@
	@echo "[Eng.TERA] $(DYNAMIC_LIB_NAME).so Created successfully"
	
# Rule to create static library
$(STATIC_LIB_DIR)/$(STATIC_LIB_NAME).a: $(OBJ)
	@mkdir -p $(STATIC_LIB_DIR)
	@ar rcs $@ $^
	@echo "[Eng.TERA] $(STATIC_LIB_NAME).a Created successfully"

# Rule to link with dynamic library
dynamic_app: $(DYNAMIC_LIB_DIR)/$(DYNAMIC_LIB_NAME).so
	@$(CC) $(APP_DIR)/$(APP_SRC) $(INCS) -L$(DYNAMIC_LIB_DIR) -l$(DYNAMIC_LIB_BASE_NAME) -Wl,-rpath=./$(DYNAMIC_LIB_DIR) -o $(APP_NAME)_dynamic
	@echo "[Eng.TERA] $(APP_NAME)_dynamic Created successfully"
	
# Rule to link with static library
static_app: $(STATIC_LIB_DIR)/$(STATIC_LIB_NAME).a
	@$(CC) $(APP_DIR)/$(APP_SRC) $(INCS) -static -L$(STATIC_LIB_DIR) -l$(STATIC_LIB_BASE_NAME) -o $(APP_NAME)_static
	@echo "[Eng.TERA] $(APP_NAME)_static Created successfully"

# Clean target
clean:
	@rm -rf $(OBJ_DIR) $(DYNAMIC_LIB_DIR) $(STATIC_LIB_DIR) $(APP_NAME)_dynamic $(APP_NAME)_static
	@echo "[Eng.TERA] Directory cleaned successfully"

# Phony targets
.PHONY: all dynamic_app static_app clean



