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
(defpackage caveman2-widgets-blog.web
  (:use :cl
        :caveman2
        :caveman2-widgets
        :caveman2-widgets-bootstrap
        :caveman2-widgets-blog.config
        :caveman2-widgets-blog.view
        :caveman2-widgets-blog.db)
  (:import-from :crane
                :filter)
  (:export :*web*))
(in-package :caveman2-widgets-blog.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Application
(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

(init-widgets *web*)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Widget classes
(defclass <blog-post-widget> (<widget>)
  ((post
    :initarg :post
    :initform (error "Must supply a BLOGPOST object.")
    :reader post)))

(defmethod render-widget ((this <blog-post-widget>))
  (render "blogpost.html"
          (list :blog (post this))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other classes
(defclass <blog-header-widget> (<header-widget>)
  ())

(defmethod initialize-instance :after ((this <blog-header-widget>) &key)
  (append-item this
               (make-instance '<css-file>
                              :path "/static/css/blog.css")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global widgets
(defvar *header-widget*
  (make-instance '<bootstrap-header-widget>
                 :title "Blog"))

(defvar *blog-widget*
  (make-widget :global '<composite-widget>
               :widgets
               (mapcar (lambda (item)
                         (make-widget :global '<blog-post-widget>
                                      :post item))
                       (filter 'blogpost))))

(defvar *contact-widget*
  (make-widget :global '<string-widget>
               :text "hello"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Routes
(defnav "/"
    (*header-widget*
     (list
      (list "Blog" "blog" *blog-widget*)
      (list "Contact" "contact" *contact-widget*))
     :kind '<bootstrap-menu-navigation-widget>))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
