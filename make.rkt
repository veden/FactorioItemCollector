(module BuildScript racket
  (provide all-defined-out)
  
  (require file/zip)
  (require json)
  
  (define modFolder "/data/games/factorio/mods/")
  (define zipModFolder "/data/games/factorio/mods/")
  (define configuration (call-with-input-file "info.json"
                          (lambda (port)
                            (string->jsexpr (port->string port)))))
  (define packageName (string-append (string-replace (hash-ref configuration 'name) " " "_")
                                     "_" 
                                     (hash-ref configuration 'version)))
  
  (define (makeZip folder)
    (let ((packagePath (string->path (string-append folder
                                                    packageName
                                                    ".zip"))))
      (when (file-exists? packagePath)
        (delete-file packagePath)))
    (zip (string-append folder
                        packageName 
                        ".zip")
         #:path-prefix packageName
         (string->path "info.json")
         (string->path "control.lua")
         (string->path "data.lua")
         (string->path "changelog.txt")
         (string->path "LICENSE.md")
         (string->path "settings.lua")
         (string->path "README.md")
         (string->path "thumbnail.png")
         (string->path "NOTICE")
         (string->path "libs")
         (string->path "locale")
         (string->path "graphics")
         (string->path "prototypes")))
  
  (define (copyFile fileName modFolder)
    (copy-file (string->path fileName)
               (string->path (string-append modFolder
                                            packageName
                                            "/"
                                            fileName))))
  
  (define (copyDirectory directoryName modFolder)
    (copy-directory/files (string->path directoryName)
                          (string->path (string-append modFolder
                                                       packageName
                                                       "/"
                                                       directoryName))))
  
  (define (copyFiles modFolder)
    (let ((packagePath (string->path (string-append modFolder
                                                    packageName))))
      (when (directory-exists? packagePath)
        (delete-directory/files packagePath))
      (sleep 0.1)
      (make-directory packagePath)
      (copyFile "control.lua" modFolder)
      (copyFile "info.json" modFolder)
      (copyFile "data.lua" modFolder)
      (copyFile "LICENSE.md" modFolder)
      (copyFile "changelog.txt" modFolder)
      (copyFile "settings.lua" modFolder)
      (copyFile "thumbnail.png" modFolder)
      (copyFile "NOTICE" modFolder)
      (copyDirectory "libs" modFolder)
      (copyDirectory "locale" modFolder)
      (copyDirectory "graphics" modFolder)
      (copyDirectory "prototypes" modFolder)))

  (define (copy)
    (copyFiles modFolder))

  (define (zipIt)
    (makeZip modFolder))
  
  (define (run)
    ;;(copyFiles modFolder)
    ;;(copyFiles zipModFolder)
    (makeZip modFolder)
    (system*/exit-code "/data/games/factorio/bin/x64/factorio")
    )
  )
