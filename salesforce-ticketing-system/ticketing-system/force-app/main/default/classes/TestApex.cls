/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TestApex {
    
    // Wrapper class for input parameters
    public class InputWrapper {
        @InvocableVariable(label='Username' required=true)
        public String username;

        @InvocableVariable(label='Password' required=true)
        public String password;
    }

    // Wrapper class for API response
    public class PostWrapper {
        public Integer userId;
        public Integer id;
        public String title;
        public String body;

        public PostWrapper(Integer userId, Integer id, String title, String body) {
            this.userId = userId;
            this.id = id;
            this.title = title;
            this.body = body;
        }
    }

    // Invocable method for flow
    @InvocableMethod(label='Authenticate User' description='Authenticates a user and fetches posts')
    public static void authenticateUserAndGetPosts(List<InputWrapper> inputList) {
        System.debug('### AuthenticateUserAndGetPosts method called ###');

        if (inputList.isEmpty()) {
            System.debug('### Error: No input provided ###');
            return;
        }

        // Call a future method to make the HTTP request
        fetchPostsAsync();
    }

    // Use @future to avoid callout restrictions in flow
    @future(callout=true)
    public static void fetchPostsAsync() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://jsonplaceholder.typicode.com/posts');
            request.setMethod('GET');

            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('### API Response: ' + response.getBody());

                // Deserialize JSON properly
                List<PostWrapper> posts = (List<PostWrapper>) JSON.deserialize(response.getBody(), List<PostWrapper>.class);
                System.debug('### Fetched Posts Count: ' + posts.size());
            } else {
                System.debug('### Error: API call failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('### Exception in fetchPostsAsync: ' + e.getMessage());
        }
    }
}
