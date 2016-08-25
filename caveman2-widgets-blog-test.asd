;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (C) 2016 Richard Bäck <richard.baeck@free-your-pc.com>
;;
;; This file is part of caveman2-widgets-blog.
;;
;; caveman2-widgets-blog is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option) any
;; later version.
;;
;; caveman2-widgets-blog is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along with
;; caveman2-widgets-blog.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :cl-user)
(defpackage caveman2-widgets-blog-test-asd
  (:use :cl :asdf))
(in-package :caveman2-widgets-blog-test-asd)

(defsystem caveman2-widgets-blog-test
  :author "Richard Paul Bäck"
  :license "GPLv3"
  :depends-on (:caveman2-widgets-blog
               :prove)
  :components ((:module "t"
                :components
                ((:file "caveman2-widgets-blog"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
