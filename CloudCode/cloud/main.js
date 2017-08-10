
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
                   
                   var utcMili = new Date();
                   var utcDate = Math.floor(Date.now() / 1000);
                   response.success(utcDate);
                   });





Parse.Cloud.job("enviarAtualizacao", function(request, status) {
                Parse.Cloud.useMasterKey();
                var CanalNotificacao = Parse.Object.extend("CanalNotificacao");
                var contador = 0;
                var date = Math.floor(Date.now() / 1000);
                var canalQuery = new Parse.Query(CanalNotificacao);
                canalQuery.each(function(canal) {
                                date = date +(2*60);
                                Parse.Push.send({
                                                channels: [canal.get("nome")],
                                                data: {
                                                alert: "Atualizar canal" + canal.get("nome")
                                                },
                                                push_time: new Date(date*1000)
                                                
                                                }, {
                                                success: function() {
                                                status.message(contador + " pushes enviados.");
                                                contador+=1;
                                                },
                                                error: function(error) {
                                                console.log(error);
                                                }
                                                });
                                }).then(function() {
                                        // Set the job's success status
                                        status.success("SUCESSO AO ENVIAR ATUALIACOES");
                                        }, function(error) {
                                        console.log(error);
                                        status.error("ALGO DEU ERRADO:" + error);
                                        });
                });


Parse.Cloud.afterSave("Atualizacao", function(request) {
                      Parse.Cloud.useMasterKey();
                      var texto = request.object.get("texto");
                      console.log("TEXTO DO PUSH: "+texto);
                      var CanalNotificacao = Parse.Object.extend("CanalNotificacao");
                      var contador = 0;
                      var date = Math.floor(Date.now() / 1000);
                      var canalQuery = new Parse.Query(CanalNotificacao);
                      canalQuery.each(function(canal) {
                                      date = date +(2*60);
                                      Parse.Push.send({
                                                      channels: [canal.get("nome")],
                                                      data: {
                                                      alert: texto
                                                      },
                                                      push_time: new Date(date*1000)
                                                      
                                                      }, {
                                                      success: function() {
                                                      status.message(contador + " pushes enviados.");
                                                      contador+=1;
                                                      },
                                                      error: function(error) {
                                                      console.log(error);
                                                      }
                                                      });
                                      });
                      
                      });


Parse.Cloud.job("jobTeste", function(request, status) {
                status.success("SUCESSO AO TESTAR O JOB: JOBTESTE");
                });
