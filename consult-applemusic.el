;;; consult-applemusic.el --- Consulting AppleMusic Libraries -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Desmond Wang
;;
;; Author: Desmond Wang <dw@dezzw.com>
;; Maintainer: Desmond Wang <dw@dezzw.com>
;; Created: March 21, 2023
;; Modified: March 21, 2023
;; Version: 0.0.1
;; Keywords: multimedia
;; Homepage: https://github.com/dezzw/consult-applemusic
;; Package-Requires: ((emacs "26.1") (consult "0.8"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'consult)
(require 'marginalia)

(defcustom consult-applemusic-marginalia t
  "Whether enable the annotation."
  :type 'boolean)

(defvar consult-applemusic-history nil)

(defun applemusic-current-playlist()
  "Return the name of playlist that currently playing."
  (do-applescript "tell application \"Music\" to get name of current playlist"))

(defun applemusic-current-song()
  "Return the name of song that currently playing."
  (do-applescript "tell application \"Music\" to get name of current track"))

(defun applemusic-get-artist(track)
  "Return the name of the artist of the given TRACK."
  (do-applescript (format "tell application \"Music\" to get name of artist of track \"%s\"" track)))

(defun applemusic-search-by (type)
  "Qury the applemusic with the given TYPE."
  (cond ((string= type "track")
	 (split-string
	  (do-applescript
	   "tell application \"Music\" to set mySong to get name of every track of playlist \"Library\"
set text item delimiters to \",\"
mySong as text") "\\,"))
	((split-string
	  (do-applescript
	   "tell application \"Music\" to set myPlaylists to get name of playlists
set text item delimiters to \",\"
myPlaylists as text") "\\,"))))

(defun consult-applemusic-by (type)
  "Consult AppleMusic by TYPE with FILTER."
  (consult--read (applemusic-search-by type)
                 :prompt (format "Search %ss: " type)
                 :lookup #'consult--lookup-member
		 :sort nil
		 :category 'applemusic-search-item
		 :history '(:input consult-applemusic-history)
		 :default (if (string= type "track") (applemusic-current-song) (applemusic-current-playlist))
		 :require-match t))

(defun applemusic--play(type name)
  "Play the whole playlist or one track of given NAME based on the TYPE."
  (do-applescript (format "tell application \"Music\" to play %s \"%s\"" type name)))

;;;###autoload
(defun applemusic-toggle-play()
  "Toggle play/pause state of current song."
  (interactive)
  (do-applescript "tell application \"Music\" to playpause"))

;;;###autoload
(defun applemusic-play-next()
  "Play next song through AppleMusic."
  (interactive)
  (do-applescript "tell application \"Music\" to play next track"))

;;;###autoload
(defun applemusic-play-prev()
  "Play previous song through AppleMusic."
  (interactive)
  (do-applescript "tell application \"Music\" to play next track"))

;;;###autoload
(defun consult-applemusic-playlists ()
  "Query applemusic for playlists using consult."
  (interactive)
  (applemusic--play "playlist" (consult-applemusic-by "playlist")))

;;;###autoload
(defun consult-applemusic-songs ()
  "Query applemusic for songs using consult."
  (interactive)
  (applemusic--play "track" (consult-applemusic-by "track")))

(provide 'consult-applemusic)
;;; consult-applemusic.el ends here
