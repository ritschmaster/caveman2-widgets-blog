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
        :cl-ppcre
        :caveman2
        :caveman2-widgets
        :caveman2-widgets-bootstrap

        :caveman2-widgets-blog.config
        :caveman2-widgets-blog.view)
  (:shadowing-import-from :caveman2-widgets-blog.db
                          :blogpost
                          :id
                          :date
                          :title
                          :text_filename)
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
;; <BLOG-POST-WIDGET> STARTS HERE
(defclass <blog-post-widget> (<widget>)
  ((post
    :initarg :post
    :initform (error "Must supply a BLOGPOST object.")
    :reader post)))

(defmethod render-widget ((this <blog-post-widget>))
  (render "blogpost.html"
          (list :blog-id (regex-replace-all " "
                                            (title (post this))
                                            "-")
                :blog-title (title (post this))
                :blog-date (date (post this))
                :blog-text
                (nth-value 1
                           (markdown (merge-pathnames
                                      (pathname
                                       (text_filename (post this)))
                                      *blog-directory*)
                                     :format :html
                                     :stream nil)))))
;; <BLOG-POST-WIDGET> ENDS HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; <BLOG-WIDGET> STARTS HERE
(defclass <blog-widget> (<composite-widget>)
  ((display-month
    :initform
    (multiple-value-bind
          (second minute hour date month year day-of-week dst-p tz)
        (get-decoded-time)
      month)
    :accessor display-month)
   (display-year
    :initform
    (multiple-value-bind
          (second minute hour date month year day-of-week dst-p tz)
        (get-decoded-time)
      year)
    :accessor display-year)))

(defmethod render-widget ((this <blog-widget>))
  (print (display-year this))
  (print 
   (display-month this))
  (setf (widgets this)
        (mapcar #'(lambda (item)
                  (make-widget :session '<blog-post-widget>
                               :post item))
                (sort (filter 'blogpost
                              (:like
                               :date
                               (format nil "~a-~2,'0d%"
                                             (display-year this)
                                             (display-month this))))
                      #'(lambda (first second)
                          (if (> (id first) (id second))
                              t
                              nil)))))
  (concatenate 'string
               (render "blog-page.html"
                       (list :title "Blog"))
               (call-next-method this)))
;; <BLOG-WIDGET> ENDS HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; <BLOG-POST-CHOOSER-WIDGET> STARTS HERE
(defun create-blog-widget ()
  (set-widget-for-session :blog-widget
                          (make-widget :session '<blog-widget>)))

(defun get-month-of-date-string (date-string)
  (declare (string date-string))
  (parse-integer (subseq date-string 5 7)))

(defun get-year-of-date-string (date-string)
  (declare (string date-string))
  (parse-integer (subseq date-string 0 4)))

(defun get-year-months-of-blogs ()
  (let ((blog-widget (get-widget-for-session :blog-widget))
        (posts (filter 'blogpost))
        (tuples '())
        (post-year nil)
        (post-month nil)
        (tuple nil))
    (dolist (post posts)
      (setf post-year (get-year-of-date-string (date post)))
      (setf post-month (get-month-of-date-string (date post)))
      (when (not (assoc post-year tuples))
        (setf tuples
              (append tuples
                      (list (list post-year)))))
      (setf tuple (assoc post-year tuples))
      (when (not (find post-month tuple))
       (setf (cdr tuple)
             (sort (append (cdr tuple)
                           (list post-month))
                   #'>))))
    tuples))

(defclass <blog-post-chooser-widget> (<composite-widget>)
  ())

(defmethod render-widget ((this <blog-post-chooser-widget>))
  (create-blog-widget)
  (setf (widgets this)nil)
  (when (null (widgets this))
    (dolist (tuple (get-year-months-of-blogs))
      (append-item this
                   (make-widget :session '<string-widget>
                                     :text (format nil "<h3>~a</h3>"
                                                   (car tuple))))
      (dolist (month (cdr tuple))
        (append-item this
                     (make-widget
                      :session '<link-widget>
                      :label (second (assoc month *month-list*))
                      :callback
                      #'(lambda (args)
                          (let ((blog-widget
                                  (get-widget-for-session :blog-widget)))
                            (setf (display-year blog-widget)
                                  (first tuple))
                            (setf (display-month blog-widget)
                                  month)
                            (mark-dirty blog-widget)
                            "")))))))
  (call-next-method this))
;; <BLOG-POST-CHOOSER-WIDGET> ENDS HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; <BLOG-PAGE-WIDGET> STARTS HERE
(defun create-border-widget ()
    (set-widget-for-session
     :border-widget
     (make-widget :session '<border-widget>
                  :center (make-widget
                           :session '<function-widget>
                                       :function
                                       #'(lambda ()
                                           (render-widget
                                            (get-widget-for-session :blog-widget))))
                  :west (make-widget :session '<blog-post-chooser-widget>))))

(defclass <blog-page-widget> (<widget>)
  ())

(defmethod render-widget ((this <blog-page-widget>))
  (create-border-widget)
  (render-widget
   (get-widget-for-session :border-widget)))
;; <BLOG-PAGE-WIDGET> ENDS HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; <CONTACT-WIDGET> STARTS HERE
(defclass <contact-widget> (<widget>)
  ())

(defmethod render-widget ((this <contact-widget>))
  (render "contact-page.html"
          (list :title "Contact"
                :name "Richard Paul Bäck"
                :street "Haupstraße 46"
                :postalcode "A-3314"
                :place "Strengberg, Lower Austria, Austria")))
;; <CONTACT-WIDGET> ENDS HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other classes
(defclass <blog-header-widget> (<bootstrap-header-widget>)
  ())

(defmethod initialize-instance :after ((this <blog-header-widget>) &key)
  (append-item this
               (make-instance '<css-file>
                              :path "/css/main.css"))
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
