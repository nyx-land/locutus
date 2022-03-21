(defpackage :locutus.submit
  (:local-nicknames (:jzon :com.inuoe.jzon))
  (:use :cl))

(in-package :locutus.submit)

(defclass album ()
  ((artist
    :initarg :artist
    :accessor artist)
   (title
    :initarg :title
    :accessor title)
   (year
    :initarg :year
    :accessor year)
   (month
    :initarg month
    :accessor month)
   (day
    :initarg day
    :accessor day)
   (tracks
    :initarg :tracks
    :initform nil
    :accessor tracks)
   (label
    :initarg :label
    :accessor label)))

(defclass mbrelease (album)
  ((discs
    :initarg :discs
    :initform nil
    :accessor discs)
   (barcode
    :initarg :barcode
    :accessor barcode)
   (parent-album-url
    :initarg :parent-album-url
    :accessor parent-album-url)
   (media-format
    :initarg :media-format
    :initform "Digital Release"
    :accessor media-format)
   (country
    :initarg :country
    :initform "XW"
    :accessor country)
   (release-type
    :initarg :release-type
    :accessor release-type)
   (packaging
    :initarg :packaging
    :initform "None"
    :accessor packaging)
   (language
    :initarg :language
    :initform "eng"
    :accessor language)
   (script
    :initarg :script
    :initform "Latn"
    :accessor script)
   (urls
    :initarg :urls
    :initform nil
    :accessor urls)
   (url
    :initarg :url
    :accessor url)))

(defclass track ()
  ((num
    :initarg :num
    :accessor num)
   (title
    :initarg :title
    :accessor title)
   (duration
    :initarg :duration
    :accessor duration)))

(defun make-scraper (url)
  (lquery:$ (initialize (dex:get url))))

(defun parse-time (duration)
  (let* ((seconds (mod duration 60))
         (minutes (/ (- duration seconds) 60))))
  (format nil "~a:~a" minutes seconds))

(defun get-tracks (tracks)
  (loop for song across tracks
        collect (make-instance
                 'track
                 :num (gethash "track_num" song)
                 :title (gethash "title" song)
                 :duration (parse-time (gethash "duration" song)))))

(defun parse-date (in-str)
  `((:year . ,(subseq in-str 7 11))
    (:month . ,(subseq in-str 3 6))
    (:day . ,(subseq in-str 0 2))))

(defun parse-album (album)
  (aref
   (jzon:parse
    (lquery:$1 album "script" (attr "data-tralbum")))
   4))

(defun scrape-album (album &key label)
  (flet ((d (x) (cdr (assoc x (parse-date (gethash "release_date" album))))))
    (let* ((scraper (make-scraper album))
           (json (parse-album scraper))
           (data (gethash
                  "current" json))
           (tracks (gethash "trackinfo" json)))
      (make-instance
       'mbrelease
       :artist (gethash "artist" data)
       :title (gethash "title" data)
       :year (d :year)
       :month (d :month)
       :day (d :day)
       :tracks (get-tracks tracks)
       :barcode (gethash "upc" data)
       :label label))))

(defun scrape-all (url &key label)
  (let* ((scraper (make-scraper url))
         (albums (lquery:$ scraper ".music-grid-item")))
    (loop for album in albums
          for link = (concatenate
                      'string
                      (trim-url url)
                      (lquery:$1 album "a" (attr "href")))
          collect (scrape-album link label))))
