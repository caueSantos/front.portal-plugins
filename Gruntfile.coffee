module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	replacements =
		'VTEX_IO_HOST': 'io.vtex.com.br'
		'VERSION': pkg.version

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean:
			main: ['build', 'build-raw', 'tmp-deploy']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**', '!**/*.less']
					dest: 'build-raw/<%= relativePath %>'
				,
					src: ['src/index.html']
					dest: 'build-raw/<%= relativePath %>/index.debug.html'
				]
			build:
				expand: true
				cwd: 'build-raw/'
				src: '**/*.*'
				dest: 'build/'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/js/'
					ext: '.js'
				]

		less:
			main:
				files:
					'build/<%= relativePath %>/style/portal-sku-selector.css': 'src/style/portal-sku-selector.less'
					'build/<%= relativePath %>/style/product-listing-mock.css': 'src/style/product-listing-mock.less'

		concat:
			dev:
				files:
					'build/js/portal-sku-selector-with-template.dev.js': ['build/templates/template-sku-selector.js', 'build/js/portal-sku-selector.js']
					'build/js/portal-minicart-with-template.dev.js': ['build/templates/template-minicart.js', 'build/js/portal-minicart.js']
					'build/js/portal-template-as-modal.dev.js': 'build/js/portal-template-as-modal.js'

		useminPrepare:
			html: ['build-raw/<%= relativePath %>/index.html', 'build-raw/<%= relativePath %>/sku-selector.html', 'build-raw/<%= relativePath %>/modal.html']

		usemin:
			html: ['build-raw/<%= relativePath %>/index.html', 'build-raw/<%= relativePath %>/sku-selector.html', 'build-raw/<%= relativePath %>/modal.html']

		karma:
			options:
				configFile: 'karma.conf.coffee'
			unit:
				background: true
			single:
				singleRun: true

		'string-replace':
			main:
				files:
					'build/<%= relativePath %>/index.html': ['build-raw/<%= relativePath %>/index.html']
					'build/<%= relativePath %>/index.debug.html': ['build-raw/<%= relativePath %>/index.debug.html']
				options:
					replacements: ({'pattern': new RegExp(key, "g"), 'replacement': value} for key, value of replacements)

			all:
				files:
					'build/button-bind-modal-api-response.html': ['build-raw/button-bind-modal-api-response.html']

				options:
					replacements: [
						pattern: '<!-- skuSelectorMock -->'
						replacement: grunt.file.read('spec/mocks/threeDimensionsSomeUnavailable.json')
					]

		dustjs:
			compile:
				files:
					'build-raw/templates/template-sku-selector.js': 'src/templates/sku-selector.dust'
					'build-raw/templates/template-minicart.js': 'src/templates/minicart.dust'

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.dust', 'src/**/*.coffee', 'spec/**/*.coffee', 'src/**/*.js', 'src/**/*.less']
				tasks: ['clean', 'concurrent:transform', 'copy:build', 'string-replace', 'karma:unit:run']

		concurrent:
			transform: ['copy:main', 'coffee', 'less', 'dustjs']

		vtex_deploy:
			main:
				options:
					buildDirectory: 'build'
			walmart:
				options:
					buildDirectory: 'build-raw'
					bucket: 'vtex-io-walmart'
					requireEnvironmentType: 'stable'

	grunt.loadNpmTasks name for name of pkg.dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'copy:build', 'string-replace', 'server', 'karma:unit', 'watch:main']
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'useminPrepare', 'concat', 'uglify', 'usemin', 'copy:build', 'string-replace'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']