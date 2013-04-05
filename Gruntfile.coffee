module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"


    stylus:
      options:
        compress: false
      default:
        files: [
          "css/opentip.css": "css/stylus/opentip.styl"
        ]

    coffee:
      default:
        expand: true
        options:
          bare: true
        cwd: "src/"
        src: [ "*.coffee" ]
        dest: "lib/"
        ext: ".js"

      # test:
      #   files:
      #     "test/test.js": "test/*.coffee"

    # component:
    #   app:
    #     output: "build/"
    #     name: "build"
    #     config: "component.json"
    #     styles: false
    #     scripts: true
    #     standalone: "Dropzone"

    # copy:
    #   component:
    #     src: "build/build.js"
    #     dest: "downloads/dropzone.js"

    # concat:
    #   amd:
    #     src: [
    #       "AMD_header"
    #       "components/component-emitter/index.js"
    #       "lib/dropzone.js"
    #       "AMD_footer"
    #     ]
    #     dest: "downloads/dropzone-amd-module.js"

    watch:
      css:
        files: "css/stylus/*.styl"
        tasks: [ "css" ]
        options: nospawn: on
    #   js:
    #     files: [
    #       "src/dropzone.coffee"
    #     ]
    #     tasks: [ "js" ]
    #     options: nospawn: on
    #   test:
    #     files: [
    #       "test/*.coffee"
    #     ]
    #     tasks: [ "coffee:test" ]
    #     options: nospawn: on

    # uglify:
    #   js:
    #     files: [
    #       "downloads/dropzone-amd-module.min.js": "downloads/dropzone-amd-module.js"
    #       "downloads/dropzone.min.js": "downloads/dropzone.js"
    #     ]



  grunt.loadNpmTasks "grunt-contrib-coffee"
  # grunt.loadNpmTasks "grunt-component-build"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  # grunt.loadNpmTasks "grunt-contrib-copy"
  # grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-watch"
  # grunt.loadNpmTasks "grunt-contrib-uglify"

  # Default tasks
  grunt.registerTask "default", [ "downloads" ]

  grunt.registerTask "css", "Compile the stylus files to css", [ "stylus" ]

  grunt.registerTask "downloads", [ "css" ]
