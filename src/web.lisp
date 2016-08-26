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
        :caveman2-widgets-blog.view)
  (:shadowing-import-from :caveman2-widgets-blog.db
                          :blogpost
                          :date
                          :title
                          :text)
  (:import-from :crane
                :filter)
  (:import-from :cl-markdown
                :markdown)
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
          (list :blog-title (title (post this))
                :blog-date (date (post this))
                :blog-text (nth-value 1
                                      (markdown (text (post this))
                                                :format :html
                                                :stream nil)))))

(defclass <blog-page-widget> (<composite-widget>)
  ()
  (:default-initargs
   ;; This sets the widgets only at compile time!
   :widgets (mapcar (lambda (item)
                      (make-widget :global '<blog-post-widget>
                                   :post item))
                    (filter 'blogpost))))

(defmethod render-widget ((this <blog-page-widget>))
  (concatenate 'string
               (render "blog-page.html"
                       (list :title "Blog"))
               (call-next-method this)))

(defclass <contact-widget> (<widget>)
  ())

(defmethod render-widget ((this <contact-widget>))
  (render "contact-page.html"
          (list :title "Contact"
                :name "Richard Paul Bäck"
                :street "Haupstraße 46"
                :postalcode "A-3314"
                :place "Strengberg, Lower Austria, Austria")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other classes
(defclass <blog-header-widget> (<bootstrap-header-widget>)
  ())

(defmethod initialize-instance :after ((this <blog-header-widget>) &key)
  (append-item this
               (make-instance '<css-file>
                              :path "/css/blog.css")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global widgets
(defvar *header-widget*
  (make-instance '<blog-header-widget>
                 :title "Blog"))

(defvar *blog-widget*
  (make-widget :global '<blog-page-widget>))

(defvar *contact-widget*
  (make-widget :global '<contact-widget>))

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
