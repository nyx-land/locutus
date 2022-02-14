(defsystem "locutus"
  :description "Resistance is futile. Your metadata will be assimilated."
  :license "ISC"
  :author "Nyx"
  :depends-on ("dexador"
               "com.inuoe.jzon")
  :components ((:module "src"
                :compontents
                ((:file "package")
                 (:file "locutus")))))
