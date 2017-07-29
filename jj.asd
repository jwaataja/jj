;;;; jj.asd

(asdf:defsystem #:jj
  :description "Common Lisp text editor"
  :author "Jason Waataja <jasonswaataja@gmail.com>"
  :license "MIT"
  :homepage "https://github.com/JasonWaataja/jj"
  :version "0.0.0"
  :depends-on (#:cl-containers #:cl-charms #:cl-ppcre #:alexandria #:split-sequence)
  :components ((:module "src"
                        :serial t
                        :components
                        ((:file "package")
                         (:file "conditions")
                         (:file "util")
                         (:file "settings")
                         (:file "buffer")
                         (:file "display")
                         (:file "time")
                         (:file "input")
                         (:file "event")
                         (:file "text")
                         (:file "mode")
                         (:file "frame")
                         (:file "selecting")
                         (:file "editing")
                         (:file "status")
                         (:file "commands")
                         (:file "bindings")
                         (:file "jj")))))
