module.exports = function(app, Book)
{
    // GET ALL BOOKS
    app.get('/api/books', function(req,res){
        res.end();
    });

    // GET SINGLE BOOK
    app.get('/api/books/:book_id', function(req, res){
        res.end();
    });

    // CREATE BOOK
    app.post('/api/books', function(req, res){
        res.end();
    });

}
