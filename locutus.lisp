(defun mb-search (param query) ;; &optional fields
  (com.inuoe.jzon:parse
   (dex:request (quri:make-uri :defaults "http://musicbrainz.org/"
                               :path (format nil "/ws/2/~a/" param)
                               :query (format nil "query=~a:~a" param (quri:url-encode
                                                                       query)))
                :headers '(("User-Agent" . "Locutus/0.0.0 (https://git.sr.ht/~nyx_land/locutus)")
                           ("Accept" . "application/json")))))
