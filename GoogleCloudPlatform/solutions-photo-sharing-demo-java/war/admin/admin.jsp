<%@page import="com.google.cloud.demo.model.PhotoManager"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"
  isELIgnored="false"%>

<%@ page import="com.google.cloud.demo.*"%>
<%@ page import="com.google.cloud.demo.model.*"%>


<html>
<head>
<link type="text/css" rel="stylesheet" href="admin.css">
<title>Upload your photo.</title>
</head>
<body>
  <%
   AppContext appContext = AppContext.getAppContext();
   PhotoManager photoManager = appContext.getPhotoManager();
   CommentManager commentManager = appContext.getCommentManager();
   PhotoServiceManager serviceManager = appContext.getPhotoServiceManager();
   String user = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID);
   String id = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID);
   Photo selectedPhoto = null;
   if (id != null && user != null) {
     selectedPhoto = photoManager.getPhoto(user, Long.parseLong(id));
   }
   String currentUserId = appContext.getCurrentUser().getUserId();
   String targetPageUrl = "/admin/admin.jsp";
%>

  <table class="layout-table">
    <tr>
      <td colspan=2 class="header-row">
        <h1>Google Cloud Demo - Photo Sharing</h1>
      </td>
    </tr>
    <tr>
      <td class="menu-column">
        <table class="menu-table">
          <tr>
            <td><a href="<%= targetPageUrl %>">Upload A New Photo...</a></td>
          </tr>
          <%
            Iterable<Photo> photos = photoManager.getOwnedPhotos(currentUserId);
                  if (photos != null) {
                    for (Photo photo : photos) {
          %>
          <tr>
            <td class="menu-item"><a
              href="<%= serviceManager.getMenuLinkUrl(targetPageUrl, photo) %>">
              <%
                  String imageUrl = serviceManager.getThumbnailUrl(photo.getBlobKey());
                              if (imageUrl != null && !imageUrl.isEmpty()) {
              %> <img src="<%=imageUrl%>" width=32 height=32>
              <%
                  }
              %>
              <%=photo.getTitle()%>
            </a></td>
          </tr>
          <%
            }
          }
          %>
          <tr>
            <td>
              <hr />
            </td>
          </tr>
          <tr>
            <td><b>Shared By Others</b></td>
          </tr>
          <%
            photos = photoManager.getSharedPhotos(currentUserId);
                  if (photos != null) {
                    for (Photo photo : photos) {
          %>
          <tr>
            <td class="menu-item"><a
              href="<%=serviceManager.getMenuLinkUrl(targetPageUrl, photo)%>"> <img
                src="<%=serviceManager.getThumbnailUrl(photo.getBlobKey())%>"
                width=32 height=32><%= photo.getTitle() %></a></td>
          </tr>
          <%
              }
            }
          %>
        </table>
      </td>
      <td class="content-column">
        <%
          if (selectedPhoto != null) {
        %>
        <table class="content-table">
          <tr>
            <td>
              <div class="image-box">
                <img
                  src="<%= serviceManager.getImageDownloadUrl(selectedPhoto)%>">
              </div>
            </td>
            <td class="image-property-column">

              <table>
                <tr>
                  <td>
                    <form action="/edit" method="get">
                      <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID %>"
                        value="<%= selectedPhoto.getOwnerId()%>" /> <input type="hidden"
                        name="id" value="<%= selectedPhoto.getId()%>" />
                      <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_TARGET_URL %>"
                        value="<%= targetPageUrl %>"/>

                      <table class="image-property-table">
                        <tr>
                          <td>Title:</td>
                          <td>
                            <%
                              if (currentUserId.equals(selectedPhoto.getOwnerId())) {
                                out.println("<input type=\"text\" name=\"title\" value=\"" +
                                    selectedPhoto.getTitle() + "\"/>");
                              } else {
                                out.println(selectedPhoto.getTitle());
                              }
                            %>
                          </td>
                        </tr>

                        <tr>
                          <td>Owner:</td>
                          <td><%= selectedPhoto.getOwnerNickname() %></td>
                        </tr>
                        <tr>
                          <td>&nbsp;</td>
                          <td>
                            <%
                              StringBuilder builder = new StringBuilder(
                                  "<input type=\"checkbox\" name=\"private\" value=\"Private\"");

                              if (!selectedPhoto.isShared()) {
                                builder.append(" checked=\"checked\"");
                              }

                              if (!currentUserId.equals(selectedPhoto.getOwnerId())) {
                                builder.append(" disabled=\"disabled\"");
                              }

                              builder.append("> Private");
                              out.println(builder.toString());
                            %>
                          </td>
                        </tr>
                        <%
                                    if (currentUserId.equals(selectedPhoto.getOwnerId())) {
                                 %>
                        <tr>
                          <td>&nbsp;</td>
                          <td><input type="submit" name="save" value="Save"> <input
                            type="submit" name="delete" value="Delete"></td>
                        </tr>
                        <%
                                    }
                                 %>
                      </table>
                    </form>
                  </td>
                </tr>
                <tr>
                  <td>
                    <form action="/post" method="post">
                      <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID %>"
                        value="<%= selectedPhoto.getOwnerId()%>" />
                      <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID %>"
                        value="<%= selectedPhoto.getId()%>" />
                      <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_TARGET_URL %>"
                        value="<%= targetPageUrl %>"/>
                      <table>
                        <tr>
                          <td><b> Comments</b></td>
                          <td align="right"><input type="submit" name="send" value="Send">
                          </td>
                        </tr>
                        <tr>
                          <td colspan="2"><input type="text" name="comment"
                            class="comment-text"></td>
                        </tr>
                      </table>
                    </form>
                    <table class="comment-table">
                      <%
                                   Iterable<Comment> comments = commentManager.getComments(selectedPhoto);
                                   int count = 0;
                                   for (Comment comment : comments) {
                                %>
                      <tr class="comment-row-<%= count %>">
                        <td><%= comment.getContent() %>
                          <div class="comment-suffix">
                            by
                            <%= comment.getCommentOwnerName() %>
                            at
                            <%= ServletUtils.formatTimestamp(comment.getTimestamp()) %></div></td>
                      </tr>
                      <%
                                    count = (count + 1) % 2;
                                   }
                                %>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
        <%
        } else {
        %>
          <form action="<%= serviceManager.getUploadUrl() %>" method="post"
            enctype="multipart/form-data">
            <input type="hidden" name="<%= ServletUtils.REQUEST_PARAM_NAME_TARGET_URL %>"
              value="<%= targetPageUrl %>"/>

            <table>
              <tr>
                <td>&nbsp;</td>
                <td><input type="file" name="photo"></td>
              </tr>
              <tr>
                <td>Title:</td>
                <td><input type="text" name="title" /></td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td><input type="checkbox" name="private"> Private</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td><input type="submit" value="Upload"></td>
              </tr>
            </table>
          </form>
        <%
        }
        %>
      </td>
    </tr>
    <tr>
      <td colspan="2" class="footer-row">Copyright ©Google, Inc.</td>
    </tr>
  </table>
</body>
</html>
