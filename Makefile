server_run:
	cd flutter_fridge_server && dart bin/main.dart

server_generate:
	cd flutter_fridge_server && serverpod generate --watch

flutter_gen:
	cd flutter_fridge_flutter && flutter packages pub run build_runner build --delete-conflicting-outputs