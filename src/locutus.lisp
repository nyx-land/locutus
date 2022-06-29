(in-package :locutus)

(defparameter *user-agent*
  "Locutus/0.0.0 (https://git.sr.ht/~nyx_land/locutus)")

(defun return-data (data-type results &optional &key (limit 10))
    (loop for k across (gethash data-type results)
      for x = 1 then (incf x)
      collect `(("name" . ,(gethash "name" k))
                ("disambiguation" . ,(gethash "disambiguation" k))
                ("score" . ,(gethash "score" k)))
      until (equalp x limit)))

(defun build-query (queries)
  (let ((encoded nil))
    (loop for x in queries
          do (progn
               (push (car x) encoded)
               (push (quri:url-encode (cdr x))
                     encoded)))
    (format nil "query=~{~a:\"~a\"~}" (reverse encoded))))

(defun mb-search (param &rest query)
  "PARAM: The search parameter, e.g. artist, release). QUERY: The search query;
must follow the pattern of KEY and QUERY, e.g. ':release \"foo\" :artist \"bar\"'"
  (let ((query (loop for (x y) on query
                     by #'cddr
                     collect (cons (string-downcase
                                    (string x))
                                   y))))
    (com.inuoe.jzon:parse
     (dex:request (quri:make-uri :defaults "http://musicbrainz.org/"
                                 :path (format nil "/ws/2/~a/" param)
                                 :query (build-query query))
                  :headers '(("User-Agent" . *user-agent*)
                             ("Accept" . "application/json"))))))

(defun mb-lookup (param mbid &rest inc)
  (let ((uri (quri:make-uri
              :defaults "http://musicbrainz.org"
              :path (format nil "/ws/2/~a/~a" param mbid))))
    (if inc (setf (quri:uri-query uri)
                  (format nil "inc=~{~a~^+~}" inc)))
    (com.inuoe.jzon:parse
     (dex:request uri
                  :headers '(("User-Agent" . *user-agent*)
                             ("Accept" . "application/json"))))))
