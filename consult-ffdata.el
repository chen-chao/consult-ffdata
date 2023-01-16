;;; consult-ffdata.el --- Use consult to access firefox data -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Chao Chen

;; Author: Chao Chen <wenbushi@gmail.com>
;; URL: https://github.com/chen-chao/consult-ffdata
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1") (consult "0.29"))
;; Keywords: convenience, tools, matching

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Call one of interactive function in this file to complete
;; the corresponding thing using `consult'.
;;
;; Current available:
;; - Firefox Bookmarks.
;; - Firefox History visits.

;;; Code:

(require 'browse-url)
(require 'counsel-ffdata)
(require 'consult)

(defvar consult-ffdata--history-firefox-bookmark)
(defvar consult-ffdata--history-firefox-history)

;;; Interactive functions

;;;###autoload
(defun consult-ffdata-firefox-bookmark (&optional force-update)
  "Search your Firefox bookmarks.

If FORCE-UPDATE? is non-nil, force update database and cache before searching."
  (interactive "P")
  (let ((name (consult--read
	       (counsel-ffdata--prepare-candidates!
		:query-stmt [:select [bm:title p:url]
				     :from (as moz_bookmarks bm)
				     :inner-join (as moz_places p)
				     :where (= bm:fk p:id)]
		:force-update? force-update
		:caller 'consult-ffdata-bookmark
		:transformer #'counsel-ffdata--bookmarks-display-transformer)
	       :prompt "Firefox bookmark: "
	       :category 'bookmark
	       :history 'consult-ffdata--history-firefox-bookmark)))
    (browse-url (car (last (split-string name))))))

;;;###autoload
(defun consult-ffdata-firefox-history (&optional force-update)
  "Search your Firefox history.

If FORCE-UPDATE? is non-nil, force update database and cache before searching."
  (interactive "P")
  (let ((name (consult--read
	       (counsel-ffdata--prepare-candidates!
		:query-stmt [:select [p:title p:url h:visit_date]
				     :from (as moz_historyvisits h)
				     :inner-join (as moz_places p)
				     :where (= h:place_id p:id)
				     :order-by (desc h:visit_date)]
		:force-update? force-update
		:caller 'consult-ffdata-history
		:transformer #'counsel-ffdata--history-display-transformer)
	       :prompt "Firefox history: "
	       :category 'bookmark
	       :history 'consult-ffdata--history-firefox-history)))
    (browse-url (car (split-string name)))))

(provide 'consult-ffdata)

;;; consult-ffdata.el ends here
