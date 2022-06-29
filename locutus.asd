(defsystem "locutus"
  :description "Resistance is futile. Your metadata will be assimilated."
  :license "ISC"
  :author "Nyx"
  :depends-on ("dexador"
               "lquery"
               "com.inuoe.jzon"
               "trivial-package-local-nicknames")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "locutus")))))
