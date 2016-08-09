#!/bin/bash
set -e

if [ "$1" == node ]; then
	: "${WORDPRESS_DB_HOST:=mysql}"
	
	if [ ! -e config.json ]; then
		awk '/^.*\"\/\/.*stop editing.*\"$/ && c == 0 { c = 1; system("cat") } { print }' config.json.example > config.json <<'EOJSON'
    "//": "nothing to be added :)",
EOJSON
	fi
	
	if [ ! -e pool_configs/dash.json ]; then
		awk '/^.*\"\/\/.*stop editing.*\"$/ && c == 0 { c = 1; system("cat") } { print }' pool_configs/dash.json.example > pool_configs/dash.json <<'EOJSON'
    "//": "nothing to be added :)",
EOJSON
	fi


	# see http://stackoverflow.com/a/2705678/433558
	sed_escape_lhs() {
		echo "$@" | sed 's/[]\/$*.^|[]/\\&/g'
	}
	sed_escape_rhs() {
		echo "$@" | sed 's/[\/&]/\\&/g'
	}
	set_config() {
		file=$1
		key=$2
		value=$3
		
		node <<EOJS

		var jsonfile = require('jsonfile');
		var _ = require('lodash');
		
		jsonfile.spaces = 4;
		
		var key = "$key";
		var value = "$value";
		
		// read in the JSON file
		jsonfile.readFile('$file', function(err, obj) {
			if (err) throw err;

			// Using another variable to prevent confusion.
			var fileObj = obj;
			
			var valueInt = parseInt(value, 10);
			value = (isNaN(valueInt)) ? value : valueInt;
			
			// Modify the file at the appropriate id
			_.set(fileObj, key , value);
			
			// Write the modified obj to the file
			jsonfile.writeFile('$file', fileObj, function(err) {
				if (err) throw err;
			});
		});
EOJS
        }

	set_config "config.json" "website.enabled" "0"
	
	set_config "pool_configs/dash.json" "enabled" "1"
	
fi

exec "$@"